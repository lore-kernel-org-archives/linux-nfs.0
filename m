From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 09 Sep 2004 12:39:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <414032C9.7090105@bio.ifi.lmu.de>
References: <413FF4EB.2070607@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5MKd-0006MM-Kc
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 03:39:11 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5MKc-0000S4-BE
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 03:39:11 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <413FF4EB.2070607@bio.ifi.lmu.de>
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

I wrote a little c program to test fsync on nfs directories (must be
called in the directory you want to check):

#include <fcntl.h>

int main() {
int dirfd;
dirfd = open(".",O_RDONLY, 0700);
if (fsync(dirfd) < 0)
   printf("failed\n");
else
   printf("succeeded\n");
}


Indeed it fails for all nfs-mounted directories when the client is running
kernel 2.6 (tried 2.6.6 and 2.6.8.1), and succeeds for clients running
kernel 2.4, with the same nfs server (regardless if the server is running
2.6 or 2.4).

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
