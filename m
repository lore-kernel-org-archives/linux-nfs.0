From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/9] mount.nfs: Fix nfs4mount_s prototype.
Date: Tue, 28 Aug 2007 07:02:34 +1000
Message-ID: <18131.15338.752272.415718@notabene.brown>
References: <20070824171111.10418.69889.stgit@monet.1015granger.net>
	<18127.22242.307898.761934@notabene.brown>
	<46D30F84.302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPljM-0000Q6-GJ
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 14:02:40 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPljQ-0001Hc-E1
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 14:02:45 -0700
In-Reply-To: message from Chuck Lever on Monday August 27
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

On Monday August 27, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Neil Brown wrote:
> >> @@ -286,13 +287,13 @@ fail:
> >>   * @extra_opts:	pointer to C string containing fs-specific mount options
> >>   *		(possibly also a return argument)
> >>   * @fake:	flag indicating whether to carry out the whole operation
> >> - * @bg:		one if this is a backgrounded mount attempt
> >> + * @child:	one if this is a backgrounded mount
> > 
> > Any reason for changing 'bg' to 'child'?
> 
> I think it's more clear about how the function is being called.

Yes, I eventually worked this out.
nfs4mount_s is firstly called with 'child' set to 0.  Then if that
fails and that 'bg' option is set, we fork and call it again with
'child' set to 1.   So 'child' is more meaningful than 'bg'.

However that handling of 'bg' seems much more simple in nfsmount_s
than in nfsmount - too simple?
With 'fg', it should try some number of times.
With 'bg', it should try once, then if that fails, fork and retry some
number of times in that background.
Are you doing the 'retry' in the kernel?  How do you tell it to only
try once before you fork for 'bg'?
Does the mount retry really need to be in the kernel?  I think that is
a very different issue that just changing the option parsing to be
string based.

Also, I just noticed the:
                    After a mount operation is backgrounded, all subsequent
       mounts  on  the  same  NFS  server will be backgrounded immediately,
       without first attempting  the  mount.

part of 'bg'.  That is awkward to implement when each individual mount
is done in a separate processes as happens with mount.nfs.   There is
code there which pretends to implement this, but of course it cannot
work and should be stripped out.
I wonder if it is worth trying to record the host name in a file so
that one instance can pass it to the next .... possibly not.  Though
the kernel could easily know that a particular server is not
responding, so the first mount attempt should give up quickly....

Just some thoughts.

NeilBrown

> 
> > And not making a matching change in nfsmount_s?
> 
> Upcoming patches will address this.

I notice that nfsmount and nfs4mount use 'running_bg'.  Not sure which
is better, but it would be nice to be consistent. 

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
