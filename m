Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fw.vincze.org ([71.184.222.21]:33648 "EHLO mailgw.vincze.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932421AbeAKPgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Jan 2018 10:36:38 -0500
Subject: Re: Varying ro/rw based on security flavor doesn't work
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
 <20180109192338.GC18087@fieldses.org>
From: Tamas Vincze <tom@vincze.org>
Message-ID: <4813ebaa-799e-6b6e-2ffb-ddf14de89b16@vincze.org>
Date: Thu, 11 Jan 2018 10:36:35 -0500
MIME-Version: 1.0
In-Reply-To: <20180109192338.GC18087@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/09/2018 02:23 PM, J. Bruce Fields wrote:
> On Tue, Jan 09, 2018 at 10:11:05AM -0500, Tamas Vincze wrote:
>> The exports man page says that one can vary ro/rw based on security
>> flavor by including multiple sec= options in /etc/exports, but it
>> seems to be broken in nfs-utils-1.3.0-0.48.el7_4.
> And is there some prevoius version that you know worked?
RedHat tested it further and it's still broken in 
nfs-utils-2.2.1-3.rc2.fc26.
It works correctly in nfs-utils-1.2.3-75.el6.

-Tamas
