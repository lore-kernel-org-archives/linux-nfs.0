Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:56229 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756438Ab3FKUWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jun 2013 16:22:49 -0400
Message-ID: <51B78716.30703@mindspring.com>
Date: Tue, 11 Jun 2013 13:22:46 -0700
From: Frank Filz <ffilz-lists@mindspring.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Frank Filz <ffilz-lists@mindspring.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>, ffilz@us.ibm.com
Subject: Re: Some pynfs updates
References: <51B75979.5070300@mindspring.com> <20130611200610.GB29634@fieldses.org>
In-Reply-To: <20130611200610.GB29634@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2013 01:06 PM, J. Bruce Fields wrote:
> On Tue, Jun 11, 2013 at 10:08:09AM -0700, Frank Filz wrote:
>> Please pull this branch from github:
>> https://github.com/ffilz/pynfs/commits/master
>
> Thanks, applied (actually from git://github.com/ffilz/pynfs.git master).
>
>> commit a6548ab80a68787dc3fcb5c8531d4d189d77c3a9
>> Author: Frank S. Filz <ffilz@us.ibm.com>
>> Date:   Wed May 1 16:06:56 2013 -0700
>>
>> Make mode 000 tests expect NFS4_OK when run as root
>>
>> They will warn if NFS4ERR_ACCESS is returned.
>
> ... though I'm not sure about this one.  root-squashing is completely
> normal, I'm not convinced it merits a warning.

Oh, didn't think about that, good point. Would you like me to submit a 
patch to make it an acceptable return?

Frank


