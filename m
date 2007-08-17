From: "chuli" <chul@cn.fujitsu.com>
Subject: [PATCH] nfsstat: without option nfsstat always output the
	statistics of Client NFS v4( though sometimes they are all zero)
Date: Fri, 17 Aug 2007 17:56:13 +0800
Message-ID: <004901c7e0b4$d8e945d0$478da70a@truly>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILybG-0003gm-4N
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 02:58:38 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILybJ-0002EC-Ed
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 02:58:42 -0700
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id E8839170094
	for <nfs@lists.sourceforge.net>; Fri, 17 Aug 2007 17:58:28 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id l7H9wSlh027525
	for <nfs@lists.sourceforge.net>; Fri, 17 Aug 2007 17:58:28 +0800
Received: from truly (unknown [10.167.141.71])
	by fnst.cn.fujitsu.com (Postfix) with ESMTP id 5C415D40CF
	for <nfs@lists.sourceforge.net>; Fri, 17 Aug 2007 18:12:05 +0800 (CST)
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

   There is a bug when using nfsstat without options, the Client NFS v4's 
statistics always are output.
    Actually it should be output when they are all zero.
    I looked up into the code and found it says "NFSv4 call counts ([0] == 
32)", but it is 35 in "/proc/net/rpc/nfs".
    So I made a patch for 
nfsstat.c(nfs-utils-1.1.0/utils/nfsstat/nfsstat.c).

    Package: nfs-utils
    Version: 1.1.0

# nfsstat
Server rpc stats:
..............
Client nfs v4:
null         read         write        commit       open         open_conf
0         0% 0         0% 0         0% 0         0% 0         0% 0 
0%
open_noat    open_dgrd    close        setattr      fsinfo       renew
0         0% 0         0% 0         0% 0         0% 0         0% 0 
0%
setclntid    confirm      lock         lockt        locku        access
0         0% 0         0% 0         0% 0         0% 0         0% 0 
0%
getattr      lookup       lookup_root  remove       rename       link
0         0% 0         0% 0         0% 0         0% 0         0% 0 
0%
symlink      create       pathconf     statfs       readlink     readdir
0         0% 0         0% 0         0% 0         0% 0         0% 0 
0%
server_caps  delegreturn
0         0% 0         0%
(all zeros!)
the patch is following:

diff -urNp nfs-utils-1.1.0.orig/utils/nfsstat/nfsstat.c 
nfs-utils-1.1.0/utils/nfsstat/nfsstat.c
--- nfs-utils-1.1.0.orig/utils/nfsstat/nfsstat.c 2007-08-17 
17:36:16.000000000 +0800
+++ nfs-utils-1.1.0/utils/nfsstat/nfsstat.c 2007-08-17 17:42:00.000000000 
+0800
@@ -28,7 +28,7 @@ static unsigned int cltv2info[20]; /* NF
 static unsigned int svcv3info[24]; /* NFSv3 call counts ([0] == 22) */
 static unsigned int cltv3info[24]; /* NFSv3 call counts ([0] == 22) */
 static unsigned int svcv4info[4]; /* NFSv4 call counts ([0] == 2) */
-static unsigned int cltv4info[34]; /* NFSv4 call counts ([0] == 32) */
+static unsigned int cltv4info[37]; /* NFSv4 call counts ([0] == 35) */
 static unsigned int svcv4opinfo[42];/* NFSv4 call counts ([0] == 40) */
 static unsigned int svcnetinfo[5]; /* 0  # of received packets
       * 1  UDP packets

Regards
Chu Li

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


begin 666 nfsstat_NFSv4_diff.patch
M9&EF9B M=7).<"!N9G,M=71I;',M,2XQ+C N;W)I9R]U=&EL<R]N9G-S=&%T
M+VYF<W-T870N8R!N9G,M=71I;',M,2XQ+C O=71I;',O;F9S<W1A="]N9G-S
M=&%T+F,*+2TM(&YF<RUU=&EL<RTQ+C$N,"YO<FEG+W5T:6QS+VYF<W-T870O
M;F9S<W1A="YC"3(P,#<M,#@M,3<@,3<Z,S8Z,38N,# P,# P,# P("LP.# P
M"BLK*R!N9G,M=71I;',M,2XQ+C O=71I;',O;F9S<W1A="]N9G-S=&%T+F,)
M,C P-RTP."TQ-R Q-SHT,CHP,"XP,# P,# P,# @*S X,# *0$ @+3(X+#<@
M*S(X+#<@0$ @<W1A=&EC('5N<VEG;F5D(&EN= EC;'1V,FEN9F];,C!=.PDO
M*B!.1@H@<W1A=&EC('5N<VEG;F5D(&EN= ES=F-V,VEN9F];,C1=.PDO*B!.
M1E-V,R!C86QL(&-O=6YT<R H6S!=(#T](#(R*2 J+PH@<W1A=&EC('5N<VEG
M;F5D(&EN= EC;'1V,VEN9F];,C1=.PDO*B!.1E-V,R!C86QL(&-O=6YT<R H
M6S!=(#T](#(R*2 J+PH@<W1A=&EC('5N<VEG;F5D(&EN= ES=F-V-&EN9F];
M-%T["2\J($Y&4W8T(&-A;&P@8V]U;G1S("A;,%T@/3T@,BD@*B\*+7-T871I
M8R!U;G-I9VYE9"!I;G0)8VQT=C1I;F9O6S,T73L)+RH@3D93=C0@8V%L;"!C
M;W5N=',@*%LP72 ]/2 S,BD@*B\**W-T871I8R!U;G-I9VYE9"!I;G0)8VQT
M=C1I;F9O6S,W73L)+RH@3D93=C0@8V%L;"!C;W5N=',@*%LP72 ]/2 S-2D@
M*B\*('-T871I8R!U;G-I9VYE9"!I;G0)<W9C=C1O<&EN9F];-#)=.R\J($Y&
M4W8T(&-A;&P@8V]U;G1S("A;,%T@/3T@-# I("HO"B!S=&%T:6,@=6YS:6=N
M960@:6YT"7-V8VYE=&EN9F];-5T["2\J(# @(",@;V8@<F5C96EV960@<&%C
=:V5T<PH@"0D)"0D@*B Q("!51% @<&%C:V5T<PH`
`
end


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
