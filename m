From: Rock Gordon <rockgordon@yahoo.com>
Subject: tar returns errors
Date: Sat, 22 Jun 2002 14:26:24 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020622212624.70758.qmail@web14808.mail.yahoo.com>
References: <2B53AD95B05ED411BE8C0008C7FA33F00467B5DA@EXSP13A>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14808.mail.yahoo.com ([216.136.224.224])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17LsOo-0002Q0-00
	for <nfs@lists.sourceforge.net>; Sat, 22 Jun 2002 14:26:26 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <2B53AD95B05ED411BE8C0008C7FA33F00467B5DA@EXSP13A>
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

Hi all,

When untarring files over an NFS mounted filesystem
(client and server both 2.4.18 vanilla), tar prints
errors like "Cannot change mode to rwxr-xr-x". When I
run  strace on tar, it prints this message:

----
utime("Documentation/", [2002/06/22-17:11:43,
2002/06/20-19:29:20]) = 72
chmod("Documentation/", 0755)           = 72
write(2, "tar: ", 5tar: )                    = 5
write(2, "Documentation/: Cannot change mo"...,
47Documentation/: Cannot change mode to rwxr-xr-x) =
47
write(2, "\n", 1
----

Now, the return value from utime and chmod are 72, but
the man page doesn't say anything about them ...

Any clues?


__________________________________________________
Do You Yahoo!?
Yahoo! - Official partner of 2002 FIFA World Cup
http://fifaworldcup.yahoo.com


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
