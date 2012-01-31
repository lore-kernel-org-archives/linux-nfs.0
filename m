Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50258 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab2AaT20 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2012 14:28:26 -0500
MIME-Version: 1.0
In-Reply-To: <4F283F7A.4020905@itwm.fraunhofer.de>
References: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
	<4F2147BA.6030607@itwm.fraunhofer.de>
	<yq1k44e1pn6.fsf@sermon.lab.mkp.net>
	<4F217F0C.6030105@itwm.fraunhofer.de>
	<yq1y5sovcyw.fsf@sermon.lab.mkp.net>
	<4F283F7A.4020905@itwm.fraunhofer.de>
Date: Tue, 31 Jan 2012 11:28:26 -0800
Message-ID: <CAF3hT9AgVpcZkGLkr4EH4x4heNFgxNykM4Mp3V_C-RBSwJh7mA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
From: Gregory Farnum <gregory.farnum@dreamhost.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org,
        Sven Breuner <sven.breuner@itwm.fraunhofer.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 31, 2012 at 11:22 AM, Bernd Schubert
<bernd.schubert@itwm.fraunhofer.de> wrote:
> I guess we should talk to developers of other parallel file systems and see
> what they think about it. I think cephfs already uses data integrity
> provided by btrfs, although I'm not entirely sure and need to check the
> code. As I said before, Lustre does network checksums already and *might* be
> interested.

Actually, right now Ceph doesn't check btrfs' data integrity
information, but since Ceph doesn't have any data-at-rest integrity
verification it relies on btrfs if you want that. Integrating
integrity verification throughout the system is on our long-term to-do
list.
We too will be said if using a kernel-level integrity system requires
using DIO, although we could probably work out a way to do
"translation" between our own integrity checksums and the
btrfs-generated ones if we have to (thanks to replication).
-Greg
