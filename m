Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:33349 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbaJIMwV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2014 08:52:21 -0400
Message-ID: <54368292.8060209@Netapp.com>
Date: Thu, 9 Oct 2014 08:41:54 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Steve French <smfrench@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: xfstests and linux nfs testing
References: <CAH2r5mt8EfVraedY2Gi31E4xQG=p=YqtAXEoH2a+FYHdmBzbqA@mail.gmail.com>
In-Reply-To: <CAH2r5mt8EfVraedY2Gi31E4xQG=p=YqtAXEoH2a+FYHdmBzbqA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think this is a bug in xfstests.  This fixes it for me, but I'm not sure what needs to be checked in the NFS case:

Anna

diff --git a/common/rc b/common/rc
index 34d7c19..e86bbfb 100644
--- a/common/rc
+++ b/common/rc
@@ -1085,9 +1085,9 @@ _require_scratch()
 _require_test()
 {
     case "$FSTYP" in
-       nfs*)
-                 _notrun "requires a test device"
-                ;;
+       #nfs*)
+        #         _notrun "requires a test device"
+       #        ;;
        cifs)
                echo $TEST_DEV | grep -q "//" > /dev/null 2>&1
                if [ -z "$TEST_DEV" -o "$?" != "0" ]; then
@@ -1097,7 +1097,7 @@ _require_test()
                     _notrun "this test requires a valid \$TEST_DIR"
                fi
                ;;
-       tmpfs)
+       tmpfs|nfs*)
                if [ -z "$TEST_DEV" -o ! -d "$TEST_DIR" ];
                then
                    _notrun "this test requires a valid \$TEST_DIR and unique $TEST_DEV"



On 10/08/14 23:09, Steve French wrote:
> Was running into a strange error with xfstests over nfs - must be
> missing something obvious since I have run it various times before.
>
> Tried the following local.config file (placed in root of xfstests directory)
>
> FSTYP=nfs
> TEST_DEV=192.168.93.152:/share-1
> TEST_DIR=/mnt/test
> NFS_MOUNT_OPTIONS='-ov3'
>
> and did
> ./check -nfs generic/001
>
> which should have worked fine, but it and the various other nfs
> capable xfstests returned
>
>      [not run] requires a test device
>
> which is weird because even setting the TEST_DEV as an environment
> variable xfstests still thought it wasn't set.
>
> Anyone have a sample NFS local.config file for xfstests which works?
>

