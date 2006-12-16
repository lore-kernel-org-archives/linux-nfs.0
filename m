From: devzero@web.de
Subject: kernel+userspace based nfsd running in parallel  on linux?
Date: Sat, 16 Dec 2006 16:20:45 +0100
Message-ID: <1499049521@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hello !

for a special scenario, i&#180;m thinking about running the classic userspace nfsd in parallel with the kernel based.

i think this _could_ be possible by binding the userspace one to the primary interface (eth0, ip 1.2.3.4) and the kernel based one to a virtual interface (eth0:1, ip 1.2.3.5)

i have done similar with other daemons, providing services on the same ports, but on different interfaces - think of apache ip-based virtual hosting which serves www.domaina.com on 1.2.3.4:80 and www.domainb.com on 1.2.3.5:80

since i`m unsure if this would work, can you experts give a comment if this should at least be possible in theory ?

if there isn&#180;t a killer argument against this (does not work by design because...), i would like to try to elaborate to make this work. if this fails because there is no way to specify a dedicated interface to listen on - maybe this could be fixed with some few modifications to the code...

regards
roland


_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=100071&distributionid=000000000066


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
