From: Raphael Clifford <raphael@clifford.net>
Subject: solaris server and firewalls
Date: Wed, 27 Aug 2003 21:11:53 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4D1089.2050207@clifford.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19s6eY-0004uN-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 13:12:27 -0700
Received: from netmail02.services.quay.plus.net ([212.159.14.221])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19s6eX-0003Mu-Vb
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 13:12:26 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I am trying to mount a solaris nfs server from my linux client.  The 
problem is how to do this without effectively disabling the linux firewall.

I understand that the official Sun solution for Sun clients is to mount 
using the -o public option.  However, I can't find any support for this 
in linux. I have copied a section of the man page below for completeness 
that describes what this option does.  My questions are
a) What can I do?
b) Could the answer be added to the firewall section of the HOWTO.  It 
must be a common situation. Where I work, for example, there are 
hundreds of linux clients per Solaris server.

Cheers,
Raphael

------- excerpt from Solaris man page --------------

  URLs and the public option
           If the public option is specified, or if the  resource
           includes and NFS URL, mount will attempt to connect to
           the server using the public file handle lookup  proto-
           col.  See Internet RFC 2054 - WebNFS Client Specifica-
           tion. If the server supports the public  file  handle,
           the attempt is successful; mount will not need to con-
           tact the server's rpcbind(1M), and the mountd(1M) dae-
           mons  to  get  the port number of the mount server and
           the initial file handle of pathname, respectively.  If
           the  NFS client and server are separated by a firewall
           that allows all outbount connections through  specific
           ports,  such as NFS_PORT, then this enables NFS opera-
           tions through the firewall. The public option and  the
           NFS  URL  can  be specified independently or together.
           They interact as specified in the following matrix:
[...]

and from the Solaris docs


    How to Mount an NFS File System Through a Firewall

   1.

      Become superuser.

   2.

      Manually mount the file system, using a command like:


# *mount -F nfs -o public bee:/export/share/local /mnt*

      In this example the file system /export/share/local is mounted on
      the local client using the public file handle. An NFS URL can be
      used instead of the standard path name. If the public file handle
      is not supported by the server bee, the mount operation will fail.

      ------------------------------------------------------------------------
      *Note - *

      This procedure requires that the file system on the NFS server be
      shared using the public option and any firewalls between the
      client and the server allow TCP connections on port 2049. Starting
      with the 2.6 release, all file systems that are shared allow for
      public file handle access.






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
