From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Sun, 26 Apr 2009 14:14:39 +1000
Message-ID: <ac442c870904252114w555b8cbcia51d28a9a11e317d@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202938.939647000@sgi.com>
	 <20090425215745.GA5088@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f112.google.com ([209.85.221.112]:54746 "EHLO
	mail-qy0-f112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbZDZEVS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2009 00:21:18 -0400
Received: by qyk10 with SMTP id 10so549652qyk.33
        for <linux-nfs@vger.kernel.org>; Sat, 25 Apr 2009 21:21:17 -0700 (PDT)
In-Reply-To: <20090425215745.GA5088@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 26, 2009 at 7:57 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 07:28:03AM +1100, Greg Banks wrote:

>> +
>> +/**
>> + * write_stats_prune_period - Set or report the period for pruning
>> + *                         old per-client/per-export stats entries,
>> + *                         in seconds.
>> + *
>> + * Input:
>> + *                   buf:            ignored
>> + *                   size:           zero
>> + *
>> + * OR
>> + *
>> + * Input:
>> + *                   buf:            C string containing an unsigned
>> + *                                   integer value representing the new value
>> + *                   size:           non-zero length of C string in @buf
>> + * Output:
>> + *   On success:     passed-in buffer filled with '\n'-terminated C string
>> + *                   containing numeric value of the current setting
>> + *                   return code is the size in bytes of the string
>> + *   On error:       return code is zero or a negative errno value
>> + */
>
> Just an idle remark, don't worry about this for now, but: we might want
> to rein in this write_*() comment format a little some day.  A lot of
> the content seems duplicated.
>

Fair comment.  Noted for later.

-- 
Greg.
