From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Fri, 3 Aug 2007 12:07:09 -0400
Message-ID: <20070803160709.GD456@fieldses.org>
References: <46ADDFB2.9070709@inf.ethz.ch>
	<20070731144824.GA15231@fieldses.org>
	<20070802113255.d686894c.jlayton@redhat.com>
	<18098.39541.547557.132952@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Stefan Walter <stefan.walter@inf.ethz.ch>,
	Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGzgI-0001Ky-20
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 09:07:14 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGzgL-0000dD-P5
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 09:07:18 -0700
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

On Fri, Aug 03, 2007 at 01:01:09PM +1000, Neil Brown wrote:
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

$ gdb vmlinux
GNU gdb 6.6-debian
...
(gdb) print sizeof(struct ip_map)
$1 = 40
(gdb) print sizeof(struct svc_export)
$2 = 136

Hm, OK, one-address-per-export loses.

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

If you use an actual collision-free hash function then the result will
be reproduceable, so you don't have to depend on temporary information
in mountd.

> So maybe we want to combine the two workable approaches.
> 
> Sometimes IPADDRESS maps to DOTTED_QUAD
> Sometimes IPADDRESS maps to LIST,OF,STRINGS,FROM,ETC,EXPORTS
> 
> Possibly the choice could be based on a command line switch.
> In the absence of such a switch, it could be based on the number of
> entries in /etc/exports.

Seems OK.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
