Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55808 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726268AbeHXTMY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Aug 2018 15:12:24 -0400
Date: Fri, 24 Aug 2018 11:37:15 -0400
To: =?utf-8?B?5bC55YmR6Jm5?= <yin-jianhong@163.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, jiyin@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: Re: [PATCH 19/24 v2] pynfs: python3 support plan: fix import
 fail on python3
Message-ID: <20180824153715.GC15219@fieldses.org>
References: <20180724103315.11618-1-jiyin@redhat.com>
 <20180823210227.GA22443@parsley.fieldses.org>
 <23d24537.3d15.16569e10094.Coremail.yin-jianhong@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <23d24537.3d15.16569e10094.Coremail.yin-jianhong@163.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 24, 2018 at 11:01:18AM +0800, 尹剑虹 wrote:
> No, see  [PATCH 24/24] pynfs: python3 support plan: fix access class var in list comprehension
>     Status:
>     '''
>     all patches works fine on python-2.7
>     and build success on python-3.6
>     but because xdrlib issue https://bugs.python.org/issue9544
>     pynfs has not been able to run on python-3.6 now
>     '''
> 
> Todo list:
>   investigate python xdrlib issue on python3 : https://bugs.python.org/issue9544
>   investigate why (python-ply >3.4) can't work with pynfs (on both python2 and python3)

OK, thanks for the explanation.

--b.
