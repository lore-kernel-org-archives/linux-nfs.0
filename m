From: "Alexander Povolotsky" <pevnev@juno.com>
Subject: Re: I have two Linux ( 2.6.8 ?)   NFS client/server problems
Date: Tue, 12 Oct 2004 00:05:02 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041011.170517.25418.13065@webmail12.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHAC2-0001Na-Pv
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 17:07:06 -0700
Received: from outbound-mail.lax.untd.com ([64.136.28.164])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CHABN-0005C4-QD
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 17:07:06 -0700
Received: from outbound29-sr.lax.untd.com (webmail12.lax.untd.com [10.130.30.152])
	by smtpout06.lax.untd.com with SMTP id AABAYYH9NANMFPLJ
	for <nfs@lists.sourceforge.net> (sender <pevnev@juno.com>);
	Mon, 11 Oct 2004 17:06:04 -0700 (PDT)
To: trond.myklebust@fys.uio.no,
	 nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Trond Myklebust wrote:

> Have you tried the form recommended by the manpage?

>  pivot_root . /tmp

yes - same failure 

> What does this have to do with NFS?

I am not an NFS expert - just looking for help here ...
Please tell what is the nature of this problem and 
how to solve it.

***********************************************************
På må , 11/10/2004 klokka 23:19, skreiv Alexander Povolotsky:

> # cd /fadsroot
> #sbin/pivot_root /fadsroot /tmp
> pivot_root: pivot_root: Device or resource busy

What does this have to do with NFS?

man pivot_root.
        EBUSY: new_root or put_old are on the current root file 
        system,  or  a file system is already mounted on put_old.

Have you tried the form recommended by the manpage?

  pivot_root . /tmp

Trond





________________________________________________________________
Speed up your surfing with Juno SpeedBand.
Now includes pop-up blocker!
Only $14.95/ month - visit http://www.juno.com/surf to sign up today!


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
