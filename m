Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fw.vincze.org ([71.184.222.21]:56277 "EHLO mailgw.vincze.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933135AbeAIPlh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 10:41:37 -0500
Received: from mail.vincze.org (unknown [10.10.0.8])
        (using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mailgw.vincze.org (Postfix) with ESMTP id 1030B1012F
        for <linux-nfs@vger.kernel.org>; Tue,  9 Jan 2018 10:11:07 -0500 (EST)
Received: from ws.vincze.org (ws.vincze.org [10.10.0.7])
        (using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
        (No client certificate requested)
        by mail.vincze.org (Postfix) with ESMTP id C54B277E4A
        for <linux-nfs@vger.kernel.org>; Tue,  9 Jan 2018 10:11:06 -0500 (EST)
To: linux-nfs@vger.kernel.org
From: Tamas Vincze <tom@vincze.org>
Subject: Varying ro/rw based on security flavor doesn't work
Message-ID: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
Date: Tue, 9 Jan 2018 10:11:05 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

The exports man page says that one can vary ro/rw based on security 
flavor by including multiple sec= options in /etc/exports, but it seems 
to be broken in nfs-utils-1.3.0-0.48.el7_4.

For example this /etc/exports:

/export/pub 10.13.0.0/16(sec=sys,ro,sec=krb5i:krb5p,rw)

results in this /var/lib/nfs/etab:

/export/pub 
10.13.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,secure,root_squash,no_all_squash,sec=krb5i:krb5p,secure,root_squash,no_all_squash)

Only the rw option is present in etab, that applies to both sec=sys and 
sec=krb5i:krb5p.

Is this bug specific to redhat or also present upstream?

Please include me in replies as I'm not subscribed to the list.

Thanks,
Tamas

