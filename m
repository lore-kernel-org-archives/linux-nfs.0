From: James Pearson <james-p@moving-picture.com>
Subject: fsid option in /etc/exports ?
Date: Thu, 17 Apr 2003 17:59:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E9EDD62.9E828279@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 196Cjq-0007Wo-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Apr 2003 09:59:55 -0700
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 3.22 #1)
	id 196CjC-0005fy-00
	for nfs@lists.sourceforge.net; Thu, 17 Apr 2003 17:59:14 +0100
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

I've just started to test the use of the fsid option, however it is not
documented in the exports man page.

Also, there is no warning if you give a fsid greater than 65535 - as
fsid is not documented, there is nothing to to say this value has to be
an unsigned short ...

I've knocked up a quick patch that may be suitable ...

James Pearson

begin 644 fsid.patch.gz
M'XL("*O<GCX``V9S:60N<&%T8V@`S5)=;]HP%'V&7W&*U/'10)-`F)J.2GW8
MI$K5.B'>QH1"<D.L)G86.P6T[K_OFM"NG=;7:5;DV-?WGG-]?`:#`71=EJHR
MYS+5Y[2S2SV*1XG0IO6I$KB+#3P/WC0<7X1!`-]U_?9P./Q[76N1U;@N*WCO
M^0L#/_0FMF3<'KP>=H^)ZSH3=XI#`&BU?H)R31`I>MI4,B[*GBJ-@TZJ13+K
M.`CZF,W@]O'CD-^*LZC"0-%ELZ5R>$4KFXP9&,&H.K<(9X&#=XH<KKQLG]A,
M2\$'7X-OLUEWZ7;Q^&AQ<#*#W3X3M':YVO1N5Q_G\[LY-W*J0YPF(=91@@//
MDD/+SE)VG&,![$AS&17,E^:YD/QGJOYEZYBQ4499@!5'A9*7!SF?M.#U\/_2
MPFY?@'V`^T?D"NXNY?%O1;,&JHW(G]SWPH9%)!L#+VK"9_4`[P+N))R,0]_[
M;>"WBU^Y>,JN#SWW;1?[WH7C^Y/&Q1;X$!C[3T^I*IY&-W-HBNN*5KF*[S5&
M'&R?8;3X8F<^M<+P\CK/U58C0BIR@MYK0P7LU0E-AY1@*TS&&;6F"KJD6*2"
MH[(NUE0YD,I`&,U8"3V(F(X'Z"641G5N^B,L,L$4#9/ER2*9Y*2//$W9L"EC
M&"$3*HDG::`53!89;#.2N!6RWH%])S=<_(I-0TGL58U>E!HFKVBME.D[#,?1
MZL#:7$YCJV378*/8I5%.MCM"5&WJPA(6M3:VJ5J*[_R:J:I`49Q9[5XJ]*P-
MWX33S9:X/Y=WF`;!.$"OEEIL)"?HC!/[(Z[G%^AVN_8%FL4-2Q?%,6G=!`XJ
M%=$]WXT>J-J;3,@-@[-L+`+K)"J*C:KVK%!3)]9YTZ(]MF9.VK\`1MH50F,%
"````
`
end


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
