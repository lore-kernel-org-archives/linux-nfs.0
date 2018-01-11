Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41002 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933098AbeAKSLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Jan 2018 13:11:18 -0500
Message-ID: <1515694263.3664.10.camel@redhat.com>
Subject: Re: Varying ro/rw based on security flavor doesn't work
From: Justin Mitchell <jumitche@redhat.com>
To: Tamas Vincze <tom@vincze.org>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Jan 2018 18:11:03 +0000
In-Reply-To: <4813ebaa-799e-6b6e-2ffb-ddf14de89b16@vincze.org>
References: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
         <20180109192338.GC18087@fieldses.org>
         <4813ebaa-799e-6b6e-2ffb-ddf14de89b16@vincze.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-01-11 at 10:36 -0500, Tamas Vincze wrote:
> On 01/09/2018 02:23 PM, J. Bruce Fields wrote:
> > On Tue, Jan 09, 2018 at 10:11:05AM -0500, Tamas Vincze wrote:
> >> The exports man page says that one can vary ro/rw based on security
> >> flavor by including multiple sec= options in /etc/exports, but it
> >> seems to be broken in nfs-utils-1.3.0-0.48.el7_4.
> > And is there some prevoius version that you know worked?
> RedHat tested it further and it's still broken in 
> nfs-utils-2.2.1-3.rc2.fc26.
> It works correctly in nfs-utils-1.2.3-75.el6.

Introduced by 37c07fa0 2016-11-22 Jianhong Yin
exportfs: remove redundant exports options output

It appears to be an attempt to quash duplicated options, but it is too
simplistic to handle this case correctly where otherwise opposing
options of ro and rw can validly both appear.


