From: Jeff Garzik <jeff@garzik.org>
Subject: major NFSv4 client regression (-rc7)
Date: Thu, 10 Jan 2008 15:41:19 -0500
Message-ID: <20080110204119.GA714@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753244AbYAJUlf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Server:		Linux 2.6.24-rc6 (x86-64/Fedora 8)
Good client:	Linux 2.6.24-rc6-ge697789d (x86-64/Fedora 7)
Bad client:	Linux 2.6.24-rc7-gfd0b45df (x86-64/Fedora 7)
Situation:	home dir via NFS

My home setup is a standard homedir-over-NFS setup, using NFSv4 on both
client and server.  I just rebooted into the latest upstream kernel, and
I am getting NFS client hangs all over the place:

	[jgarzik@core firefox]$ cat profiles.ini 

	hangs here, for 15 minutes so far and counting...
	('core' is the client machine)

and I first noticed this when firefox and thunderbird were hanging, when
I tried to start them after rebooting into the latest kernel.  stracing
firefox yielding a hang in open:

	("/g" is the NFS-mounted volume)

	access("/usr/lib64/firefox-2.0.0.10/updates", F_OK) = -1 ENOENT (No such file or directory)
	access("/g/g/.mozilla/firefox", F_OK)   = 0
	access("/g/g/.mozilla/firefox", F_OK)   = 0
	stat("/g/g/.mozilla/firefox/profiles.ini", {st_mode=S_IFREG|0664, st_size=94, ...}) = 0
	open("/g/g/.mozilla/firefox/profiles.ini", O_RDONLY

	hangs here, for 20 minutes so far and counting...

As you can see from the trace, and as I can report simply by being able
to send this message, SOME file accesses over NFS work just fine.

Accessing the file works when logged into the server, so its not disk
corruption or something like that.

Neither client nor server have anything interesting in dmesg -- in fact
nothing in dmesg beyond the normal boot messages have been printed.

Let me know what info I can provide...  This is a 100% reproducible
regression, and this latest NFS client revision has made my local
NFS-over-homedir setup completely unusable.  I am forced to return to
the known working client (Linux 2.6.24-rc6-ge697789d) just to run basic
apps.

	Jeff



