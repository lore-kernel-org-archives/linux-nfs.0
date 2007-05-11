From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Memory leak in mountd
Date: Fri, 11 May 2007 12:49:06 +0200
Message-ID: <20070511104906.GA21288@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmSgQ-0007H1-GO
	for nfs@lists.sourceforge.net; Fri, 11 May 2007 03:49:10 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HmSgS-0001to-1A
	for nfs@lists.sourceforge.net; Fri, 11 May 2007 03:49:13 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1HmSgL-0001Bu-9p
	for nfs@lists.sourceforge.net; Fri, 11 May 2007 12:49:05 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1HmSgM-0005Xn-00
	for <nfs@lists.sourceforge.net>; Fri, 11 May 2007 12:49:06 +0200
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

Hi,

A user complained that mountd was slowly eating up all available memory with
about a mount per second. We tracked it down, and ended up with the following
patch:

  In client_compose(), free() the hostent structure returned before
  exiting. Normally, gethostbyaddr() returns a pointer to a static
  struct, but this hostent comes from either get_reliable_hostbyaddr() or
  get_hostent(), both which return a pointer they privately xmalloc()ed,
  which thus can and should be free()d.

  Signed-Off-By: Steinar H. Gunderson <sesse@debian.org>

  --- nfs-utils-1.1.0.orig/support/export/client.c
  +++ nfs-utils-1.1.0/support/export/client.c
  @@ -262,6 +262,7 @@ client_compose(struct in_addr addr)
                          name = add_name(name, clp->m_hostname);
                  }
          }
  +       free(he);
          return name;
   }

The patch was against 1.0.10 (Debian stable), but should be equivalently
applied for 1.1.0. (Also, we backported the add_name() leak fix.) In
addition, there's a leak in innetgr() (in glibc) that hits mountd quite hard
when using netgroups, but it appears to already be fixed in at least Red Hat,
and I guess this is the wrong place to complain about glibc issues :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
