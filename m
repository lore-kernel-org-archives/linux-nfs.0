From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: Unable to handle kernel NULL pointer dereference at virtual
 address ..
Date: Thu, 24 Apr 2003 16:57:38 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0304241649460.7493-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030423181404.15518.qmail@web11403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198iAY-0002l6-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 07:57:50 -0700
To: Abhishek Rai <abbashake007@yahoo.com>
In-Reply-To: <20030423181404.15518.qmail@web11403.mail.yahoo.com>
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

On Wed, 23 Apr 2003, Abhishek Rai wrote:

> virtual address 0000000f

is exactly...

> c6675024   ecx: 00000001   edx: 00000007

... EDX + 8 which is obtained here:

>  0:   39 42 08         cmp   %eax,0x8(%edx)   <=====

> ... a 'cmp' instruction: a mere register operation.

This statement means that you do not understand asm syntax properly. 
Placing a register between paranthesis ( "(" and ")" ) is like 
dereferencing a pointer in C - access the data that is at the address 
found in the register; the 0x8(%edx) notation means 0x8 bytes offset 
from the address in EDX.

If you want live debugging, you could try kdbg...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
