From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd closes port 2049
Date: Thu, 18 Oct 2007 16:30:03 +1000
Message-ID: <18198.64875.25036.248314@notabene.brown>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, righiandr@users.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiOtc-0000sA-DX
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 23:30:16 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiOtc-0002bm-HV
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 23:30:21 -0700
In-Reply-To: message from Talpey, Thomas on Tuesday October 16
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

On Tuesday October 16, Thomas.Talpey@netapp.com wrote:
> At 05:57 PM 10/15/2007, Andrea Righi wrote:
> >Neil Brown wrote:
> >>> The weird thing is that at a certain point the socket opened on port
> >>> 2049 on the NFS server is being closed for unknown reasons (or better
> >>> for unknown reasons for me!).
> >> 
> >> This is fixed in any release based on 2.6.16.31 or later.
> >> The relevant mainline patch is 
> >>     1a047060a99f274a7c52cfea8159e4142a14b8a7
> >> as below.
> >> So update your kernel package.
> >
> >Thanks Neil, looking at the source and in my logs this seems to explain
> >perfectly my problem. I'll try the patch ASAP.
> 
> BTW, the nfsd_acceptable() issue is different from this one, and the
> no_subtree_check I suggested may still be needed (right Neil?). I'm
> interested in what you find - keep us posted.

I don't know exactly what you mean by "the nfsd_acceptable() issue",
but whatever it is, it would be completely separate from tcp
connections.

If a filesystems got unexported, or a "chmod -x" made some directories
unaccessible, it would not close any TCP connection.  It would simply
return an error status for every request, leaving the TCP connection
active.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
