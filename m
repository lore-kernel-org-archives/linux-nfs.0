Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbbDBTu7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 15:50:59 -0400
Date: Thu, 2 Apr 2015 15:50:54 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Sean Brisbane <sean.brisbane@physics.ox.ac.uk>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Per process accounting for nfs
In-Reply-To: <C6A70F0B3785A04BA88C056A0B39627C21A1BAB4@EXCHNG15.physics.ox.ac.uk>
Message-ID: <alpine.OSX.2.19.9992.1504021537360.710@planck.local>
References: <C6A70F0B3785A04BA88C056A0B39627C21A1BAB4@EXCHNG15.physics.ox.ac.uk>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-446203518-1428004256=:710"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-446203518-1428004256=:710
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 2 Apr 2015, Sean Brisbane wrote:

> Dear All,
>
> I'm currently trying to identify a mechanism to measure NFS I/o per process on a multi user NFS client machine. Lots of googling tells me this is not straight forward. Installing a kernel or module is an option if necessary, though we are also supporting afs and lustre on the same kernel (RHEL 6 based). The purpose of this is to gather accurate metrics on the workload types we run to feed into what hardware we need to buy. Can anyone give me any pointers as to how to proceed?
>
> Thanks,
> SeanN?????r??y??????X??ǧv???)޺{.n??????{???????n?r??????????????&????G?????(?階?ݢj"????m????????ޖ???f???h???~?m?

Hi Sean,

Systemtap can do that.. and ftrace might also work for that.  Check those
out.

Ben
--0-446203518-1428004256=:710--
