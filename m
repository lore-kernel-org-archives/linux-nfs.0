From: Anoop Thomas <anoop.r.thomas@gmail.com>
Subject: Trouble with mounting NFS filesystem
Date: Sun, 13 Mar 2005 17:03:05 +0900
Message-ID: <358fd27c05031300038ea4a51@mail.gmail.com>
Reply-To: Anoop Thomas <anoop.r.thomas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAO4A-0002UW-Cz
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 00:03:14 -0800
Received: from wproxy.gmail.com ([64.233.184.206])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DAO48-0007so-0A
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 00:03:14 -0800
Received: by wproxy.gmail.com with SMTP id 50so1692229wri
        for <nfs@lists.sourceforge.net>; Sun, 13 Mar 2005 00:03:05 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi,

I'm Anoop from India. I'm doing a project on Diskless cluster for my
college. I have encountered a problem while setting the client side
configuration.

I have configured the DHCP, TFTP and PXE servers.
Plus i have configured the NFS and NIS servers . All of them are on a
single machine.
I've even compiled a kernel for the slave nodes .

Everything works fine while booting up the client. Right from getting
it's IP address, to loading the kernel, booting with it etc etc. ..
but

when it tries to start the portmapper .. it says 

/etc/init.d/portmap .. line 1 : id not found
/etc/init.d/portmap .. line 39 : [ : = : Unary operator expected
Mounting NFS Filesystems   : 


and here .. it either stuck or taking too much time.. it does not load
the NFS filesystems..
i think i waited too long once to see a timeout. 

Its managed to take the root file system while loadin the kernel... so
exporting my filesystem from server is ok.

This is how my /etc/fstab for the slave looks like :

192.168.1.1:/usr		/usr		nfs	defaults	0 0
192.168.1.1:/home		/home		nfs	defaults	0 0
192.168.1.1:/tftpboot/dual2	/		nfs	defaults	0 0	
none                    /dev/pts       	    	devpts  gid=5,mode=620  0 0
none                    /proc                   proc    defaults        0 0
none                    /dev/shm                tmpfs   defaults        0 0


ip address for my server is below
for slave its 192.168.1.2.
if i remove the first 3 lines of /etc/fstab .. it reaches the login
screen without the filesystems and bash cant recognise most of the
usual commands like rpcinfo, ntsysv etc etc ...

Pls help me. I'm just a newbie in linux. Reply to me in this address asap


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
