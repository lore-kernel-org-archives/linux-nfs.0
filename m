Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f44.google.com ([209.85.212.44]:57129 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab3EDUX4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 16:23:56 -0400
Received: by mail-vb0-f44.google.com with SMTP id e13so2151933vbg.17
        for <linux-nfs@vger.kernel.org>; Sat, 04 May 2013 13:23:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130504130033.GB13770@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130504130033.GB13770@amd.pavel.ucw.cz>
Date: Sat, 4 May 2013 13:23:54 -0700
Message-ID: <CAMbhsRS6+hjTmrihVzgu3Dtyp8XAhJJ4VKMj=28G6xH3H73=6Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
From: Colin Cross <ccross@android.com>
To: Pavel Machek <pavel@ucw.cz>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        Linux PM list <linux-pm@vger.kernel.org>, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 4, 2013 at 6:00 AM, Pavel Machek <pavel@ucw.cz> wrote:
> Hi!
>
>> NFS calls the freezable helpers with locks held, which is unsafe
>> and caused lockdep warnings when 6aa9707 "lockdep: check that no
>> locks held at freeze time" was applied (reverted in dbf520a).
>> Add new *_unsafe versions of the helpers that will not run the
>> lockdep test when 6aa9707 is reapplied, and call them from NFS.
>>
>> Signed-off-by: Colin Cross <ccross@android.com>
>
> Looks mostly good.
>
>> @@ -152,6 +169,14 @@ static inline bool freezer_should_skip(struct task_struct *p)
>>       freezer_count();                                                \
>>  })
>>
>> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> +#define freezable_schedule_unsafe()                                  \
>> +({                                                                   \
>> +     freezer_do_not_count();                                         \
>> +     schedule();                                                     \
>> +     freezer_count_unsafe();                                         \
>> +})
>> +
>
> Make it inline function? :-). Add short explanation why it is good
> idea?

These are exact copies of the existing non-unsafe versions, except
they call freezer_count_unsafe() instead of freezer_count().  The next
version of my other patch stack that goes on top of this has a patch
to convert the macros in this file to static inline functions (at
least the ones that can be).  I'd rather not mix it in with this patch
for ease of comparison with the existing calls.

>> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> +#define freezable_schedule_timeout_killable_unsafe(timeout)          \
>> +({                                                                   \
>> +     long __retval;                                                  \
>> +     freezer_do_not_count();                                         \
>> +     __retval = schedule_timeout_killable(timeout);                  \
>> +     freezer_count_unsafe();                                         \
>> +     __retval;                                                       \
>> +})
>
> Function too?
>                                                                         Pavel
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
