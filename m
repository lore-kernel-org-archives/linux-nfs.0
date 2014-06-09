Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:63200 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbaFIJzf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 05:55:35 -0400
MIME-Version: 1.0
In-Reply-To: <005501cf7b5f$4e4359a0$eaca0ce0$@opengridcomputing.com>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
	<005501cf7b5f$4e4359a0$eaca0ce0$@opengridcomputing.com>
Date: Mon, 9 Jun 2014 12:55:34 +0300
Message-ID: <CAJZOPZ+SBT=yX3v4kvzg4TsZU2=L-05r3=ht-4y86Ox44M3mpQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/24] Series short description
From: Or Gerlitz <or.gerlitz@gmail.com>
To: Steve Wise <swise@opengridcomputing.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Roland Dreier <roland@kernel.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2014 at 7:59 PM, Steve Wise <swise@opengridcomputing.com> wrote:
> I tested this series over cxgb4 and mlx4, running cthon04, fio read/rand-rw, and xfstests, and over mthca cthon04.  No regressions.

Steve, Chuck, all

Where this series stands? I don't see it in Roland's tree for-next
branch... is this planned to go upstream through another maintainer
tree? if not, I think we're good to go, so Roland, are you picking it
up?

Or.
