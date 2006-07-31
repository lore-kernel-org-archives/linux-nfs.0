From: "bruce" <bedouglas@earthlink.net>
Subject: RE: nfs questions!!!
Date: Mon, 31 Jul 2006 11:43:59 -0700
Message-ID: <04b901c6b4d1$49e88ea0$0301a8c0@Mesa.com>
References: <9e1340d20607311048r1d4e3d40ub35b65157d2fee77@mail.gmail.com>
Reply-To: bedouglas@earthlink.net,
	For users of Fedora Core releases <fedora-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <fedora-list-bounces@redhat.com>
To: "'For users of Fedora Core releases'" <fedora-list@redhat.com>
In-Reply-To: <9e1340d20607311048r1d4e3d40ub35b65157d2fee77@mail.gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Sender: fedora-list-bounces@redhat.com
Errors-To: fedora-list-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

hi...

further research hasn't solved the issue.

i have the server nfs
  /etc/exports
     /college		192.168.1.*(rw)

i have the client nfs/mount
   mount -o rw  192.168.1.52:/college	/college

when i add a file to the share as client1, the client and the nfs server can
edit the file with no problem. the other clients can't!! in fact, the file
attributes are changed/set to some very large number...

if i go to the nfs server, and i  make the changes to the file
(chmod,chgrp,chown) then the settings are somewhat seen by the other
clients, and each client can then edit the given files on the nfs share...

i would have thought that there should be a way to set up the nfs, so that
client1 can create/add a file, and that client2 can edit the file, and vice
versa....

searching via google seems to indicate that this should work, but i can't
see how to get it to perform.

thanks

ps. yeah, there are read/write privs on the nfs mount for the clients
    and yeah, the user is the same on each machine



-----Original Message-----
From: Thom Paine [mailto:painethom@gmail.com]
Sent: Monday, July 31, 2006 10:49 AM
To: bedouglas@earthlink.net; For users of Fedora Core releases
Subject: Re: nfs questions!!!


Do you have a user with the same name and password on both hosts?
Does said user have write permissions on the directory?
Is this root? Then you need a change to your exports line.

/video  10.10.10.0/24(rw,no_root_squash)

That is the line I use for my mythbox.


--
-=/>Thom

-- 
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: https://www.redhat.com/mailman/listinfo/fedora-list
