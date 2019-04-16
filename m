Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 027A5C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:23:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D0ED020868
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 18:23:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727136AbfDPSXW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 14:23:22 -0400
Received: from mx1.redhat.com ([209.132.183.28]:56460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727067AbfDPSXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 14:23:21 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9E8EB308795B;
        Tue, 16 Apr 2019 18:23:21 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-181.phx2.redhat.com [10.3.117.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B94495D71A;
        Tue, 16 Apr 2019 18:23:19 +0000 (UTC)
Subject: Re: [nfs-utils PATCH RFC v3 0/8] restore nfsdcld
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
References: <20190326220730.3763-1-smayhew@redhat.com>
 <20190416164645.GC3430@fieldses.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <e6a67a19-4613-3353-0c67-4a97abbcf05d@RedHat.com>
Date:   Tue, 16 Apr 2019 14:23:19 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190416164645.GC3430@fieldses.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 16 Apr 2019 18:23:21 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/16/19 12:46 PM, J. Bruce Fields wrote:
> I've really only skimmed the changelogs and documentation and such, but
> that all looks good to me, and I'm still expecting to commit the
> kernel-side patches for 5.2, so I'm favor of these nfs-utils patches
> instead, as long as they look good to Steve.
They look reasonable to me... Committed!!

steved.

> 
> --b.
> 
> On Tue, Mar 26, 2019 at 06:07:22PM -0400, Scott Mayhew wrote:
>> When nfsdcld was released, it was quickly deprecated in favor of the
>> nfsdcltrack usermodehelper, so as to not require another running daemon.
>> The nfsdcld code was removed from nfs-utils in 2012.  That prevents
>> NFSv4 clients from reclaiming locks from nfsd's running in containers,
>> since neither nfsdcltrack nor the legacy client tracking code work in
>> containers.  These patches restore the nfsdcld code.
>>
>> These patches are intended to go alongside some kernel patches that
>> introduce an enhancement that allows nfsd to "slurp" up the client
>> records during client tracking initialization and store them internally
>> in hash table.  This enables nfsd to check whether an NFSv4 client is
>> allowed to reclaim without having to do an upcall to nfsdcld.  It also
>> allows nfsd to decide to end the v4 grace period early if the number of
>> RECLAIM_COMPLETE operations it has received from "known" clients is
>> equal to the number of entries in the hash table.  It also allows nfsd
>> to skip the v4 grace period altogether if it knows there are no clients
>> allowed to reclaim.
>>
>> The new nfsdcld code will work with older kernels, however in that case
>> there is no ability for nfsd to exit the grace period early or skip the
>> grace period altogether.
>>
>> v3:
>> - removed PathExists restriction from the nfsdcld.service file
>> - added the ability to do a one-time upgrade from older client tracking
>>   methods (i.e. nfsdcltrack and/or the legacy v4recovery dir)
>> v2:
>> - Use sqlite3_column_int64() instead of sqlite3_column_int() to query
>>   the current & recovery values from the grace table
>> - Uncommented the nfsdcld section header in nfs.conf
>>
>> Scott Mayhew (8):
>>   Revert "nfsdcltrack: remove the nfsdcld daemon"
>>   nfsdcld: move nfsdcld to its own directory
>>   nfsdcld: a few enhancements
>>   nfsdcld: remove some unused functions
>>   nfsdcld: the -p option should specify the rpc_pipefs mountpoint
>>   nfsdcld: add /etc/nfs.conf support
>>   systemd: add a unit file for nfsdcld
>>   nfsdcld: add a facility for migrating from older client tracking
>>     methods
>>
>>  .gitignore                   |    1 +
>>  configure.ac                 |   23 +
>>  nfs.conf                     |    4 +
>>  support/include/cld.h        |    1 +
>>  systemd/nfs-server.service   |    2 +
>>  systemd/nfsdcld.service      |   10 +
>>  utils/Makefile.am            |    4 +
>>  utils/nfsdcld/Makefile.am    |   19 +
>>  utils/nfsdcld/cld-internal.h |   33 +
>>  utils/nfsdcld/legacy.c       |  180 ++++++
>>  utils/nfsdcld/legacy.h       |   24 +
>>  utils/nfsdcld/nfsdcld.c      |  774 ++++++++++++++++++++++++
>>  utils/nfsdcld/nfsdcld.man    |  199 ++++++
>>  utils/nfsdcld/sqlite.c       | 1109 ++++++++++++++++++++++++++++++++++
>>  utils/nfsdcld/sqlite.h       |   35 ++
>>  15 files changed, 2418 insertions(+)
>>  create mode 100644 systemd/nfsdcld.service
>>  create mode 100644 utils/nfsdcld/Makefile.am
>>  create mode 100644 utils/nfsdcld/cld-internal.h
>>  create mode 100644 utils/nfsdcld/legacy.c
>>  create mode 100644 utils/nfsdcld/legacy.h
>>  create mode 100644 utils/nfsdcld/nfsdcld.c
>>  create mode 100644 utils/nfsdcld/nfsdcld.man
>>  create mode 100644 utils/nfsdcld/sqlite.c
>>  create mode 100644 utils/nfsdcld/sqlite.h
>>
>> -- 
>> 2.17.2
