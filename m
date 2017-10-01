Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blatinox.fr ([51.254.120.209]:33833 "EHLO vps202351.ovh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751672AbdJATlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 1 Oct 2017 15:41:15 -0400
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?=
        <jeremy.lefaure@lse.epita.fr>
Cc: alsa-devel@alsa-project.org, amd-gfx@lists.freedesktop.org,
        brcm80211-dev-list@cypress.com,
        brcm80211-dev-list.pdl@broadcom.com, devel@acpica.org,
        devel@driverdev.osuosl.org, dm-devel@redhat.com,
        dri-devel@lists.freedesktop.org, ecryptfs@vger.kernel.org,
        intel-gfx@lists.freedesktop.org,
        intel-gvt-dev@lists.freedesktop.org,
        intel-wired-lan@lists.osuosl.org,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-acpi@vger.kernel.org, linux-integrity@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-video@atrey.karlin.mff.cuni.cz,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        nouveau@lists.freedesktop.org,
        openipmi-developer@lists.sourceforge.net
Subject: [PATCH 00/18] use ARRAY_SIZE macro
Date: Sun,  1 Oct 2017 15:30:38 -0400
Message-Id: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: unlisted-recipients:; (no To-header on input)@mail.corp.redhat.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everyone,
Using ARRAY_SIZE improves the code readability. I used coccinelle (I
made a change to the array_size.cocci file [1]) to find several places
where ARRAY_SIZE could be used instead of other macros or sizeof
division.

I tried to divide the changes into a patch per subsystem (excepted for
staging). If one of the patch should be split into several patches, let
me know.

In order to reduce the size of the To: and Cc: lines, each patch of the
series is sent only to the maintainers and lists concerned by the patch.
This cover letter is sent to every list concerned by this series.

This series is based on linux-next next-20170929. Each patch has been
tested by building the relevant files with W=1.

This series contains the following patches:
[PATCH 01/18] sound: use ARRAY_SIZE
[PATCH 02/18] tracing/filter: use ARRAY_SIZE
[PATCH 03/18] media: use ARRAY_SIZE
[PATCH 04/18] IB/mlx5: Use ARRAY_SIZE
[PATCH 05/18] net: use ARRAY_SIZE
[PATCH 06/18] drm: use ARRAY_SIZE
[PATCH 07/18] scsi: bfa: use ARRAY_SIZE
[PATCH 08/18] ecryptfs: use ARRAY_SIZE
[PATCH 09/18] nfsd: use ARRAY_SIZE
[PATCH 10/18] orangefs: use ARRAY_SIZE
[PATCH 11/18] dm space map metadata: use ARRAY_SIZE
[PATCH 12/18] x86: use ARRAY_SIZE
[PATCH 13/18] tpm: use ARRAY_SIZE
[PATCH 14/18] ipmi: use ARRAY_SIZE
[PATCH 15/18] acpi: use ARRAY_SIZE
[PATCH 16/18] media: staging: atomisp: use ARRAY_SIZE
[PATCH 17/18] staging: rtl8723bs: use ARRAY_SIZE
[PATCH 18/18] staging: rtlwifi: use ARRAY_SIZE


[1]: https://lkml.org/lkml/2017/9/13/689
