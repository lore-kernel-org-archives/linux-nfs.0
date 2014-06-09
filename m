Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43108 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932277AbaFINLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2014 09:11:54 -0400
Message-ID: <5395B291.9050501@netapp.com>
Date: Mon, 9 Jun 2014 09:11:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Or Gerlitz <or.gerlitz@gmail.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Roland Dreier" <roland@kernel.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v5 00/24] Series short description
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>	<005501cf7b5f$4e4359a0$eaca0ce0$@opengridcomputing.com> <CAJZOPZ+SBT=yX3v4kvzg4TsZU2=L-05r3=ht-4y86Ox44M3mpQ@mail.gmail.com>
In-Reply-To: <CAJZOPZ+SBT=yX3v4kvzg4TsZU2=L-05r3=ht-4y86Ox44M3mpQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/09/2014 05:55 AM, Or Gerlitz wrote:
> On Thu, May 29, 2014 at 7:59 PM, Steve Wise <swise@opengridcomputing.com> wrote:
>> I tested this series over cxgb4 and mlx4, running cthon04, fio read/rand-rw, and xfstests, and over mthca cthon04.  No regressions.
> 
> Steve, Chuck, all
> 
> Where this series stands? I don't see it in Roland's tree for-next
> branch... is this planned to go upstream through another maintainer
> tree? if not, I think we're good to go, so Roland, are you picking it
> up?
> 
> Or.

This is going through the NFS tree (Trond should already have it).

Anna
> 

