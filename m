From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH v2] nfs-utils: mountd: Use a dynamic buffer for storing
 lists of gid's
Date: Thu, 21 Apr 2011 08:26:36 -0400
Message-ID: <4DB0227C.7070701@RedHat.com>
References: <1302261406-9048-1-git-send-email-sean.finney@sonyericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Sean Finney <sean.finney@sonyericsson.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387Ab1DUM0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Apr 2011 08:26:39 -0400
In-Reply-To: <1302261406-9048-1-git-send-email-sean.finney@sonyericsson.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/08/2011 07:16 AM, Sean Finney wrote:
> Previously, in auth_unix_gid, group lists were stored in an array of
> hard-coded length 100, and in the situation that the group lists for a
> particular call were too large, the array was swapped with a dynamically
> allocated/freed buffer.  For environments where users are commonly in
> a large number of groups, this isn't an ideal approach.
> 
> Instead, use malloc/realloc to grow the list on an as-needed basis.
> 
> Signed-off-by: Sean Finney <sean.finney@sonyericsson.com>
My bad... I committed this early this week and forgot to 
acknowledge on the list... Sorry about that... 

steved. 
