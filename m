From: "Joseph L. Hood" <nfsmail@acerbus.com>
Subject: Re: wanted: RH7.3 mods to NFS + ipchains HOWTO
Date: Fri, 16 Aug 2002 12:42:22 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208161235250.14704-100000@linux2>
References: <200208161628.AA08532@argus.nofs.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from staffordstudio.com ([66.92.164.68] helo=linux2.staffordstudio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fkAs-0006d4-00
	for <nfs@lists.sourceforge.net>; Fri, 16 Aug 2002 09:42:10 -0700
Received: from localhost (jhood@localhost)
	by linux2.staffordstudio.com (8.11.6/8.11.6) with ESMTP id g7GGgMx15350
	for <nfs@lists.sourceforge.net>; Fri, 16 Aug 2002 12:42:22 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <200208161628.AA08532@argus.nofs.navy.mil>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Edit your /etc/init.d/nfs file and add near the top:

# Pick the port for Mountd to stay with
MOUNTD_PORT=39338

Then restart NFS.

This will keep mountd on the same port all of the time.

For real security use either NFS over SSH 
(http://www.samag.com/documents/s=4072/sam0203d/sam0203d.htm) or NFS over 
CIPE (Crypto IP Encryption -- which is included with RedHat 7.2 and 7.3).

The port 715 is a source port, which doesn't really matter in this 
instance, you only care about destination port.

Joe

On Fri, 16 Aug 2002 blaise@nofs.navy.mil wrote:

> On Thu, 15 Aug 2002 blaise@nofs.navy.mil wrote:
> 
> > I am trying to set up NFS on a LAN of RH7.3 (2.4.18-3) boxes with their
> > ipchains firewalls running ("high" security, *not* trusting
> > other machines connected to their eth0 port).
> > 
> > The NFS HOWTO describes in detail how to get NFS through
> > an ipchains firewall by specifying which ports mountd,
> > statd, and lockd use.
> > 
> > I am starting mountd on port 32790 (from /etc/init.d/nfs),
> > statd on -p=32791 and -o=32792 (from /etc/init.d/nfslock),
> > and lockd on 32793 (from /etc/modules.conf).
> > 
> > Having done this, something is still broken.  For instance,
> > here is the rejection log when host nova (192.168.48.150)
> > tries to mount a partition on novus (192.168.48.151):
> > 
> > Aug 15 15:19:25 nova automount[1109]: attempting to mount entry /nofs/novus
> > Aug 15 15:19:25 nova kernel: Packet log: input REJECT eth0 PROTO=17
> > 192.168.48.151:32790 192.168.48.150:715 L=84 S=0x00 I=0 F=0x4000 T=64 (#17)
> > 
> > Here are the relevant ipchains lines:
> > 
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 -j ACCEPT -f
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 32790:32793 -p 6 -j ACCEPT
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 32790:32793 -p 17 -j ACCEPT
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 2049:2049 -p 6 -j ACCEPT
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 2049:2049 -p 17 -j ACCEPT
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 111:111 -p 6 -j ACCEPT
> > -A input -s 192.168.48.0/255.255.255.0 -d 0.0.0.0/0.0.0.0 111:111 -p 17 -j ACCEP
> > 
> > Why is nova (...150) using port 715?  This port is surely blocked by the
> > ipchains firewall, resulting in the rejection.  Shouldn't it be using port
> > 32790?  rpcinfo -p on nova shows that mountd is running on port 32790.  
> > 
> > Also, rpcinfo -p shows that "nlockmgr" is running on 32768.  Is this relevant?
> > 
> > Any help would be thoroughly appreciated.  Thanks.
> > 
> > -- Blaise
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 







-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
