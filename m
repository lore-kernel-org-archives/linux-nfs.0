From: "Steve Wolfe" <nw@codon.com>
Subject: More on the unmountable volumes...
Date: Wed, 26 Feb 2003 13:38:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000b01c2ddd7$145224b0$88693fd1@WEASEL>
References: <shshec9p7zs.fsf@charged.uio.no><Pine.LNX.4.40.0301161226270.26507-100000@bolt.sonic.net> <15963.42061.837369.881024@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from local.iboats.com ([209.63.105.131])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18o8Fb-0006eA-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Feb 2003 12:33:59 -0800
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


 A week or so ago, I send a message to the list about some volumes that
would not mount from a particular client.  I've come across something that
allows me to mount the volumes, but not particularly well.

  If I try and mount a volume normally, I'll get "RPC Timed out".  If I
watch tcpdump, all communications will work for about 200 packets, then
the client won't be able to get packets to mountd on the server.  There is
no firewalling taking place between the two.

  Here's where it gets interesting:  If I shut down NFS on the server,
then start it back up, and try and mount a volume (say, /home) from the
client immediately, it will work.  But if I wait a few minutes after
restarting the NFS server, it will *not* work.  It gets even better:  If I
restart NFS on the server, and mount a volume from the client immediately,
it will work - BUT, I will not be able to mount another volume from that
client unless I restart NFS on the server *again* - and I have to repeat
for each of the several volumes that I have to mount.  But, I did get all
of the volumes mounted last night.  Today, however, one one of the
volumes, I got a stale NFS handle error, so I had to restart the NFS
server, then remount the volume.  Quite unpleasant!

  This is really weird.  And it only happens from this one client.   I've
ruled out hardware issues, and even copied the entire OS from one of the
other functioning clients.  I really do wonder if it could be a problem on
the server side, and would appreciate any suggestions or help.

steve




-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
