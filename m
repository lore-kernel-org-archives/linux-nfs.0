From: Jeff Layton <jlayton@redhat.com>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Fri, 3 Aug 2007 11:45:37 -0400
Message-ID: <20070803114537.8d605487.jlayton@redhat.com>
References: <46ADDFB2.9070709@inf.ethz.ch>
	<20070731144824.GA15231@fieldses.org>
	<20070802113255.d686894c.jlayton@redhat.com>
	<18098.39541.547557.132952@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGzLP-0007dR-26
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 08:47:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGzLS-0000vQ-Db
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 08:45:43 -0700
In-Reply-To: <18098.39541.547557.132952@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 3 Aug 2007 13:01:09 +1000
Neil Brown <neilb@suse.de> wrote:

> On Thursday August 2, jlayton@redhat.com wrote:
> > 
> > I started having a look at this today. The original patches that I
> > proposed to clean up the rmtab a few months ago also eliminated this
> > comma-delimited string. Neil had valid objections to it at the time,
> > but if we switched to using the IP address as a cache key like Bruce
> > describes then doing that becomes more reasonable.
> > 
> > The only downside I see is the one Bruce points out -- the size of
> > the kernel export cache would increase. I don't have a feel for whether
> > this is a show stopper, however.
> > 
> > Neil, do you have thoughts on what you'd consider a reasonable approach
> > to fixing this?
> > 
> 
> I'm having troubling visualising the problematic setup.  Is it
> possible to get a copy of the /etc/exports file, and some idea of what
> hosts are in which netgroups?  Knowing that would help assess the
> appropriateness of various solutions.
> 
> 
> The core issue is this:
> 
>  We need to map IPADDRESS to THING, and  THING + PATH to EXPORTPOINT.
> (roughly).
> So what do we choose for "THING"?
> 
> One obvious option is the dotted quad of the IP address.
> People tend to have large sets of similar clients, so doing this seems
> to be missing out on a valuable optimisation and adding bloat to the
> lookup tables in the kernel.
> 
> Another apparently obvious solution is to use FQDN, but we really
> don't want to do that, as a multihomed host might have one IP address
> that you want to trust, and another that you don't (as the subnet is
> less secure against forgery).  It doesn't help must over dotted-quad
> anyway.
> 
> Another option is to use whatever strings are included in /etc/exports
> to identify things.  e.g. *.my.domain or @mynetgroup.
> This seems simple and elegant, but it can be messy in some
> situations.  In particular, if one IP address matches several strings,
> which one do you use?  We have to use them all.
> One path might be exported to *.my.domain and a different path might
> be exported to @mynetgroup.  If a.b.c.d is in both of those sets of
> machines, then the THING that a.b.c.d is mapped to must allow the
> correct
>     THING + PATH -> EXPORTPOINT
> mapping for both paths.
>     *.my.domain,@mynetgroup
> works quite effectively.
> But if you have lots and lots of different netgroups mentioned in
> /etc/exports, and one machine is in all of those netgroups, then you
> have to generate a very long string @a,@b,@c,@d,.....
> 
> I guess we could use a hash and keep a hash table in mountd.
> So mountd:
>   1/ Generates the comma-separated name as needed, being careful to
>      allocate enough space.
>   2a/ If this is small enough, write it to the kernel as is.
>   2b/ If it is too big, Find it in a table (adding if needed) and 
>       write the address of the table entry to the kernel
> 
>   When a THING + PATH request arrives:
>     If THING looks like an address in the table, do the lookup to get
>     the string.
> 
> This would work to keep the strings in the kernel shorter, but is
> rather ugly - storing in the kernel addresses in a user-space program.
> 

Hmm, and if you stop mountd and restart it those addresses would change
(or do the caches get flushed when that occurs?).

We could hash the strings here and use those as keys in a search.h
hashtable. It still wouldn't be friendly to look at, but should keep
things relatively constant across repeated invocations of mountd.

I think the following idea is probably better though...

> Also, if you have lots of netgroups mentioned, then finding out which
> ones contain a given IP address might be slow, and all the information
> isn't really needed.  Once you get THING, it will be paired with a
> specific path, so you only really need to look up netgroups that are
> related to that path.
> 
> So maybe we want to combine the two workable approaches.
> 
> Sometimes IPADDRESS maps to DOTTED_QUAD
> Sometimes IPADDRESS maps to LIST,OF,STRINGS,FROM,ETC,EXPORTS
> 
> Possibly the choice could be based on a command line switch.
> In the absence of such a switch, it could be based on the number of
> entries in /etc/exports.
> 
> 	int i;
> 	int size = 0;
> 	nfs_client	*clp;
> 
> 	for (i = 0 ; i < MCL_MAXTYPES; i++)
> 		for (clp = clientlist[i]; clp ; clp = clp->m_next)
> 			size += strlen(clp->m_hostname)+1;
> 
> 	if (size > 1000)
> 		use DOTTED_QUAD;
> 	els
> 		don't.
> 


The second scheme seems like the most feasible to me. While it does
have more potential to bloat out the caches, it seems like it has the
most potential to reduce the number of netgroup lookups in the future.
That would be a very good thing.

One thing I'm not clear on is the length limit for the "domain" string
in the kernel caches. I've looked over the code, but it hasn't jumped
out at me. What is the limit there?

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
