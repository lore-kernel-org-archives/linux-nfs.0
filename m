From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: Large export list leads to "Invalid argument" errors when
 executing 'exportfs -r'
Date: Thu, 28 Aug 2003 10:56:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4DC3AE.7040003@inf.ethz.ch>
References: <1057405449.3361.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sIZn-0000vk-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 01:56:19 -0700
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sIZm-0000i0-GB
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 01:56:18 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 5682259D4B
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 10:56:15 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 04807-01-10 for <nfs@lists.sourceforge.net>;
 Thu, 28 Aug 2003 10:56:14 +0200 (MEST)
Received: from inf.ethz.ch (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 87CE159C2D
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 10:56:14 +0200 (MEST)
In-Reply-To: <1057405449.3361.64.camel@localhost>
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

Marc Schmitt wrote:

>Hi all,
>
>I'm using RedHat 7.3 as NFS server, kernel 2.4.18-27.7.xsmp, nfs-utils
>1.0.3.
>
>For each home directory, we make an entry into /etc/exports of the type:
>
>/export/home/<login> @<login>(rw,sync)
>
>The @<login> netgroups contain usually a whole bunch of machines in FQDN
>notation.
>
>This setup used to work fine, I could add a new entry to /etc/exports
>and issue 'exportfs -r' and everything would work as expected, the new
>home could be mounted on the machines in @<login>.
>
>Somehow, with /etc/exports growing more and more (currently 137
>entries), 'exportfs -r' started giving errors of the type:
>
><somehost part of @<login>>:/export/home/<login>: Invalid argument
>
>Currently, I get three of those error lines for three entries in
>/etc/exports. Lokks like it fails when it tries to unexport the entry,
>'exportsfs -r -v' shows:
>
>unexporting <somehost part of @<login>>:/export/home/<login> from kernel
><somehost part of @<login>>:/export/home/<login>: Invalid argument
>
>I made several tests, even when I delete the line in /etc/exports for
><login>, 'exportfs -r' will still give this error. I've deleted the
>corresponding entry in /var/lib/nfs/xtab but 'exportfs -r' would just
>add it again, obviously it's cached in the kernel table.
>
>Looking at 'showmount -a', I noticed that the server thinks, that
><somehost> has /export/home/<login> mounted, still. Even though the
>client does not have the home mounted from the server. I mounted the
>home on <somehost>, unmounted and issued 'exportfs -r' on the server and
>the error message "somehost part of @<login>>:/export/home/<login>:
>Invalid argument" did not appear again.
>
FYI: this problem went away with the update from nfs-utils 1.0.3 to 
1.0.5. Since the update, even though the export table has grown 
considerably again menawhile, I have not seen the "Invalid argument" 
error again.

Greetz
    Marc



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
