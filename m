From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 02/23] mount.nfs: fix printf's normally
 hidden	behind NFS_MOUNT_DEBUG
Date: Mon, 30 Jul 2007 13:32:29 -0400
Message-ID: <46AE20AD.4010107@RedHat.com>
References: <20070728214918.21871.38740.stgit@localhost.localdomain>
	<46ADD039.9070405@RedHat.com> <46ADFC9C.8050503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFZ6a-0000xa-4J
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 10:32:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFZ6d-0007FH-Oe
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 10:32:32 -0700
In-Reply-To: <46ADFC9C.8050503@oracle.com>
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

Chuck Lever wrote:
> Steve Dickson wrote:
>> Chuck Lever wrote:
>>> After I enabled NFS_MOUNT_DEBUG the compiler started spitting out 
>>> warnings.
>>> Fix up commas, output formatting, and double-wide character support.
>> Aren't these debugging statements basically useless because one has to
>> recompile to turn them on... Wouldn't it make more sense to add
>> '-o mntdebug' flag so these could be turned on at will?
> 
> Useless for folks who don't want to or can't compile nfs-utils 
> themselves, yes.  But I think the usefulness of these is for anyone who 
> is developing mount.  They aren't for debugging problems mounting 
> shares, but for debugging changes to mount itself.
> 
> I'm not opposed to making these debugging messages available dynamically 
> (if we really believe they will be useful for everyday system 
> administrators).... but....
> 
> Miklos has illuminated an important distinction between mount options 
> that affect the behavior of the mounted file system, and mount options 
> that control who can mount and how the mount takes place.  NFS is one of 
> the worst offenders in mixing the two.
> 
> A "mntdebug" option would be of the latter type, and I'm beginning to 
> think twice about the value of adding more of these.  I'm thinking about 
> a way of specifying those types of options in some other way; for 
> example, by using a separate NFS mount policy file like nsswitch.conf to 
> set these up.  Just a random thought.
> 
> Or, rather, instead of "-o mntdebug" we might consider --mntdebug 
> instead; that is, use a command line option instead of a mount option.
> 
> It's a nit, I know.
Right... a command line option to the actual mount binary is probably
the way to go... The binary could pass a MS_DEBUG flag to the mount.nfs
binary which would enable the debugging...

steved.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
