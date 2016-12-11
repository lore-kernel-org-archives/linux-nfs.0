Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34195 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753553AbcLKSDh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 13:03:37 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBBHx4aL115369
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 13:03:36 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
        by mx0a-001b2d01.pphosted.com with ESMTP id 278yr02p61-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 13:03:36 -0500
Received: from localhost
        by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <xinhui@linux.vnet.ibm.com>;
        Sun, 11 Dec 2016 23:33:33 +0530
Subject: Re: [PATCH v2 1/1] lockd: Change nsm_use_hostnames from bool to u32
To: Jia He <hejianet@gmail.com>, linux-nfs@vger.kernel.org
References: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
 <1481470609-31488-2-git-send-email-hejianet@gmail.com>
 <819a5924-6fd4-adce-c03f-2a83c99d0a27@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Date: Mon, 12 Dec 2016 02:03:27 +0800
MIME-Version: 1.0
In-Reply-To: <819a5924-6fd4-adce-c03f-2a83c99d0a27@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Message-Id: <8a609db8-b715-4aad-913e-62fe8f6ec45d@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



在 2016/12/12 01:43, Pan Xinhui 写道:
>
> hi, jia
>     nice catch!
> However I think we should fix it totally.
> This is because do_proc_dointvec_conv() try to get a int value from a bool *.
>
> something like below might help. pls. ignore the code style and this is tested :)
									_untested_.

