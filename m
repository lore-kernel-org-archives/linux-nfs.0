From: Jeff Layton <jlayton@redhat.com>
Subject: [Fwd:  [PATCH 1/2] idmapd: plug memory leak in dirscancb]
Date: Tue, 02 Jan 2007 13:06:13 -0500
Message-ID: <459A9F15.9060602@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050504020704080802030409"
Cc: NFSv4@linux-nfs.org, nfs@lists.sourceforge.net,
	kwc@citi.umich.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H1o1o-0005Re-Qq
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 10:06:24 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H1o1o-0002xA-VF
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 10:06:26 -0800
To: neilb@suse.de
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

This is a multi-part message in MIME format.
--------------050504020704080802030409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Neil,
   I sent these patches out in late October, but have noticed that they have not 
yet made it into your git tree. Is there anything preventing them from going in?

Thanks,
Jeff

--------------050504020704080802030409
Content-Type: message/rfc822;
	name="[NFS] [PATCH 1/2] idmapd: plug memory leak in dirscancb"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename*0="[NFS] [PATCH 1/2] idmapd: plug memory leak in dirscancb"

Return-Path: <nfs-bounces@lists.sourceforge.net>
X-Spam-Checker-Version: SpamAssassin 3.1.3 (2006-06-01) on
	salusa.poochiereds.net
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=2.0 tests=AWL,BAYES_00,
	FORGED_RCVD_HELO autolearn=ham version=3.1.3
X-Original-To: jtlayton@poochiereds.net
Delivered-To: jtlayton@poochiereds.net
Received: from lists-outbound.sourceforge.net (lists-outbound.sourceforge.net
	[66.35.250.225])
	by mail.poochiereds.net (Postfix) with ESMTP id EA4ADC0129
	for <jtlayton@poochiereds.net>; Thu, 26 Oct 2006 14:44:00 -0400 (EDT)
Received: from sc8-sf-list2-new.sourceforge.net (unknown [10.3.1.94])
	by sc8-sf-spam2.sourceforge.net (Postfix) with ESMTP
	id C339E138EB; Thu, 26 Oct 2006 11:43:59 -0700 (PDT)
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdACq-0003by-8p
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:43:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GdACp-00034N-V7
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:43:57 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9QIhlaI011230
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:47 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9QIhlrj030978
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:47 -0400
Received: from tleilax.poochiereds.net (vpn-14-145.rdu.redhat.com
	[10.11.14.145])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9QIhgvi005100
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 14:43:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: nfs@lists.sourceforge.net
Date: Thu, 26 Oct 2006 14:43:41 -0400
Message-Id: <1161888221.2667.40.camel@tleilax.poochiereds.net>
Mime-Version: 1.0
X-Mailer: Evolution 2.6.3 (2.6.3-1.fc5.5) 
Subject: [NFS] [PATCH 1/2] idmapd: plug memory leak in dirscancb
X-BeenThere: nfs@lists.sourceforge.net
X-Mailman-Version: 2.1.8
Precedence: list
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

There is a pretty nasty memory leak in idmapd in dirscancb(). Some of
our customers have reported that idmapd can eat gigabytes of memory on
machines with a large number of mounts and unmounts and a long uptime.

That function uses scandir(), which malloc's an array of strings, but
dirscancb() never frees the strings or the array. The following patch
should correct this, but I've not yet tested it on 1.0.10 (only on the
RHEL4 1.0.6 version). Still, the code is very similar and I'm fairly
certain the problem exists in both versions.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/idmapd/idmapd.c.leak
+++ nfs-utils-1.0.10/utils/idmapd/idmapd.c
@@ -464,7 +464,7 @@ dirscancb(int fd, short which, void *dat
 				goto next;
 
 			if ((ic = calloc(1, sizeof(*ic))) == NULL)
-				return;
+				goto out;
 			strlcpy(ic->ic_clid, ents[i]->d_name + 4,
 			    sizeof(ic->ic_clid));
 			path[0] = '\0';
@@ -474,7 +474,7 @@ dirscancb(int fd, short which, void *dat
 			if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
 				idmapd_warn("dirscancb: open(%s)", path);
 				free(ic);
-				return;
+				goto out;
 			}
 
 			strlcat(path, "/idmap", sizeof(path));
@@ -486,7 +486,7 @@ dirscancb(int fd, short which, void *dat
 			if (nfsopen(ic) == -1) {
 				close(ic->ic_dirfd);
 				free(ic);
-				return;
+				goto out;
 			}
 
 			ic->ic_id = "Client";
@@ -512,6 +512,11 @@ dirscancb(int fd, short which, void *dat
 		} else
 			ic->ic_scanned = 0;
 	}
+
+out:
+	for (i = 0;  i < nent; i++)
+		free(ents[i]);
+	free(ents);
 	return;
 }
 



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


--------------050504020704080802030409
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------050504020704080802030409
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050504020704080802030409--
