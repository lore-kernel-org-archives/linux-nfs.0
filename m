From: "Padmakiran K. S." <padmakiran@gmail.com>
Subject: Cross compilation of nfs-utils-1.0.9.tar.gz for mips
	architecture.
Date: Mon, 20 Nov 2006 17:30:29 +0530
Message-ID: <e4c2e66b0611200400l1f47b04j1ef3c87a7492f81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1959416345=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gm7pA-0002C8-RM
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 04:00:36 -0800
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gm7p8-00053a-LD
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 04:00:31 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1119759ugc
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 04:00:30 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1959416345==
Content-Type: multipart/alternative;
	boundary="----=_Part_76442_25412792.1164024029564"

------=_Part_76442_25412792.1164024029564
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all,

I am trying to enable NFS support enabled for Monta Vista linux 2.6.10 for
mips architecture. I was not able to cross-compile the nfs-utils package
that was downloaded from sourceforge.net site.

I tried setting (env variable) CC to my cross compiler
i.emips64_octeon_be-gcc and tried the configure script as mentioned
below.
--host option of configure script was set to the output of config.guessscript.

./configure --host=i686-pc-linux-gnu

checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
appending configuration tag "F77" to libtool
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... yes
checking for g77 option to produce PIC... -fPIC
checking if g77 PIC flag -fPIC works... yes
checking if g77 static flag -static works... yes
checking if g77 supports -c -o file.o... yes
checking whether the g77 linker
(/auto/itasca/tools/packages/montavisa/mvl402/montavista/pro/devkit/mips64/octeon_be/mips64octeon-montavista-linux/bin/ld)
supports shared libraries... yes
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking for i686-pc-linux-gnu-ar... (cached) i686-pc-linux-gnu-ar
checking for i686-pc-linux-gnu-ld...
/auto/itasca/tools/packages/montavisa/mvl402/montavista/pro/devkit/mips64/octeon_be/mips64octeon-montavista-linux/bin/ld
checking for ANSI C header files... (cached) yes
checking for GNU libc2... yes
checking for BSD signal semantics... configure: error: cannot run test
program while cross compiling


My build keeps failing for BSD signal semantics.  Is there any method of
suppressing this check in the configure script.
Any link or url elaborating the cross compilation for nfs-utils package
would also be of great help.

Is this the right method to cross compile nfs-utils package ? Currently i'm
using the package nfs-utils-1.0.9.tar.gz.

Thanks and Regards,
Padmakiran

------=_Part_76442_25412792.1164024029564
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all,<br><br>I am trying to enable NFS support enabled for Monta Vista linux 2.6.10 for mips architecture. I was not able to cross-compile the nfs-utils package that was downloaded from <a href="http://sourceforge.net">sourceforge.net
</a> site.<br><br>I tried setting (env variable) CC to my cross compiler i.e mips64_octeon_be-gcc and tried the configure script as mentioned below. --host option of configure script was set to the output of config.guess script.
<br><br>./configure --host=i686-pc-linux-gnu <br><br>checking dynamic linker characteristics... GNU/Linux ld.so<br>checking how to hardcode library paths into programs... immediate<br>appending configuration tag &quot;F77&quot; to libtool
<br>checking if libtool supports shared libraries... yes<br>checking whether to build shared libraries... yes<br>checking whether to build static libraries... yes<br>checking for g77 option to produce PIC... -fPIC<br>checking if g77 PIC flag -fPIC works... yes
<br>checking if g77 static flag -static works... yes<br>checking if g77 supports -c -o file.o... yes<br>checking whether the g77 linker (/auto/itasca/tools/packages/montavisa/mvl402/montavista/pro/devkit/mips64/octeon_be/mips64octeon-montavista-linux/bin/ld) supports shared libraries... yes
<br>checking dynamic linker characteristics... GNU/Linux ld.so<br>checking how to hardcode library paths into programs... immediate<br>checking for i686-pc-linux-gnu-ar... (cached) i686-pc-linux-gnu-ar<br>checking for i686-pc-linux-gnu-ld... /auto/itasca/tools/packages/montavisa/mvl402/montavista/pro/devkit/mips64/octeon_be/mips64octeon-montavista-linux/bin/ld
<br>checking for ANSI C header files... (cached) yes<br>checking for GNU libc2... yes<br>checking for BSD signal semantics... configure: error: cannot run test program while cross compiling<br><br><br>My build keeps failing for BSD signal semantics.&nbsp; Is there any method of suppressing this check in the configure script. 
<br>Any link or url elaborating the cross compilation for nfs-utils package would also be of great help. <br><br>Is this the right method to cross compile nfs-utils package ? Currently i'm using the package nfs-utils-1.0.9.tar.gz
.<br><br>Thanks and Regards,<br>Padmakiran<br>

------=_Part_76442_25412792.1164024029564--


--===============1959416345==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1959416345==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1959416345==--
