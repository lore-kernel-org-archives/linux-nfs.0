From: "Shannon Skerritt" <shannon@thousandhillservices.com>
Subject: NFS problem: rpc.mountd: can't stat exported dir /home/.hidden
Date: Tue, 14 Aug 2007 16:42:37 +0100
Message-ID: <b5ff9fe50708140842k9657506y50ed486a02407002@mail.gmail.com>
References: <b5ff9fe50708140841n3ae2e34fpe44e9526f5c200fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKyap-0004mG-R2
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 08:46:04 -0700
Received: from nz-out-0506.google.com ([64.233.162.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKyXa-0003oV-Ut
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 08:42:43 -0700
Received: by nz-out-0506.google.com with SMTP id f1so2441728nzc
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 08:42:39 -0700 (PDT)
In-Reply-To: <b5ff9fe50708140841n3ae2e34fpe44e9526f5c200fd@mail.gmail.com>
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

Hi all,

I am hoping that someone can assist me with an interesting problem. I
have a RHEL WS4 workstation client that is accessing an NFS share via
AUTOFS.

-- /etc/auto.master

/misc /etc/auto.misc --timeout=60
/home /etc/auto.home --timeout=60

-- /etc/auto.misc

share1 -rw,intr,bg,rsize=32768,wsize=32768 server:/share1

-- /etc/auto.home

* -rw,intr,bg,rsize=32768,wsize=32768 server:/home/&

The workstations authenticate via OpenLDAP and the above obviously
means that home directories are served via NFS on demand. This all
works well but I have noticed I am starting to get interesting errors
when browsing NFS shares particularly using Nautilus/GNOME on the
workstations.

NFS config on the server:

-- /etc/exports

/home x.x.x.x/255.255.255.0(rw)

On the client:

automount[5619]: >> mount: brimstone:/home/.hidden failed, reason
given by server: No such file or directory
automount[5619]: mount(nfs): nfs: mount failure server1:/home/.hidden
on /home/.hidden
automount[5619]: failed to mount /home/.hidden

On the server:

rpc.mountd: authenticated mount request from workstation:797 for
/home/.hidden (/home)
rpc.mountd: can't stat exported dir /home/.hidden: No such file or directory

Occasionally, I'll get references to /home/.directory instead of /home.hidden.

The above can fill the logs and cause serious system slow down, again
occasionally at the rate of a mount a second on the NFS server.

1. Why are the clients looking for these files?
2. How do stop this behaviour?

I'm not sure if the above is related (but it certainly sounds like it)
- but does anyone also have any ideas on how I can disable gam_server?
It appears it may be part of the problem as per this:
http://mail.gnome.org/archives/gamin-list/2006-March/msg00007.html

Any thoughts?

Regards,
Shannon.

--
Shannon Skerritt
Thousand Hill Services Limited
Email: shannon@thousandhillservices.com

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
