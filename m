Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75D43C433F5
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jan 2022 18:01:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236044AbiADSBF convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Jan 2022 13:01:05 -0500
Received: from out03.mta.xmission.com ([166.70.13.233]:48840 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234971AbiADSBD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2022 13:01:03 -0500
Received: from in01.mta.xmission.com ([166.70.13.51]:57206)
        by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1n4o7C-00Fz0d-Et; Tue, 04 Jan 2022 11:00:55 -0700
Received: from ip68-110-24-146.om.om.cox.net ([68.110.24.146]:33276 helo=email.froward.int.ebiederm.org.xmission.com)
        by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1n4o73-006IOp-EO; Tue, 04 Jan 2022 11:00:50 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     Walt Drummond <walt@drummond.us>
Cc:     aacraid@microsemi.com, viro@zeniv.linux.org.uk,
        anna.schumaker@netapp.com, arnd@arndb.de, bsegall@google.com,
        bp@alien8.de, chuck.lever@oracle.com, bristot@redhat.com,
        dave.hansen@linux.intel.com, dwmw2@infradead.org,
        dietmar.eggemann@arm.com, dinguyen@kernel.org,
        geert@linux-m68k.org, gregkh@linuxfoundation.org, hpa@zytor.com,
        idryomov@gmail.com, mingo@redhat.com, yzaikin@google.com,
        ink@jurassic.park.msu.ru, jejb@linux.ibm.com, jmorris@namei.org,
        bfields@fieldses.org, jlayton@kernel.org, jirislaby@kernel.org,
        john.johansen@canonical.com, juri.lelli@redhat.com,
        keescook@chromium.org, mcgrof@kernel.org,
        martin.petersen@oracle.com, mattst88@gmail.com, mgorman@suse.de,
        oleg@redhat.com, pbonzini@redhat.com, peterz@infradead.org,
        rth@twiddle.net, richard@nod.at, serge@hallyn.com,
        rostedt@goodmis.org, tglx@linutronix.de,
        trond.myklebust@hammerspace.com, vincent.guittot@linaro.org,
        x86@kernel.org, linux-kernel@vger.kernel.org,
        ceph-devel@vger.kernel.org, kvm@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-m68k@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org
References: <20220103181956.983342-1-walt@drummond.us>
Date:   Tue, 04 Jan 2022 12:00:34 -0600
In-Reply-To: <20220103181956.983342-1-walt@drummond.us> (Walt Drummond's
        message of "Mon, 3 Jan 2022 10:19:48 -0800")
Message-ID: <87iluzidod.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-XM-SPF: eid=1n4o73-006IOp-EO;;;mid=<87iluzidod.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.110.24.146;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/0+Xd8qpWrAnE4XcvYwEAmBpc7eG84nVw=
X-SA-Exim-Connect-IP: 68.110.24.146
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 0/8] signals: Support more than 64 signals
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Walt Drummond <walt@drummond.us> writes:

> This patch set expands the number of signals in Linux beyond the
> current cap of 64.  It sets a new cap at the somewhat arbitrary limit
> of 1024 signals, both because it’s what GLibc and MUSL support and
> because many architectures pad sigset_t or ucontext_t in the kernel to
> this cap.  This limit is not fixed and can be further expanded within
> reason.

Ahhhh!!

Please let's not expand the number of signals supported if there is any
alternative.  Signals only really make sense for supporting existing
interfaces.  For new applications there is almost always something
better.

In the last discussion of adding SIGINFO
https://lore.kernel.org/lkml/20190625161153.29811-1-ar@cs.msu.ru/ the
approach examined was to fix SIGPWR to be ignored by default and to
define SIGINFO as SIGPWR.

I dug through the previous conversations and there is a little debate
about what makes sense for SIGPWR to do by default.  Alan Cox remembered
SIGPWR was sent when the power was restored, so ignoring SIGPWR by
default made sense.  Ted Tso pointed out a different scenario where it
was reasonable for SIGPWR to be a terminating signal.

So far no one has actually found any applications that will regress if
SIGPWR becomes ignored by default.  Furthermore on linux SIGPWR is only
defined to be sent to init, and init ignores all signals by default so
in practice SIGPWR is ignored by the only process that receives it
currently.

I am persuaded at least enough that I could see adding a patch to
linux-next and them sending to Linus that could be reverted if anything
broke.

Where I saw the last conversation falter was in making a persuasive
case of why SIGINFO was interesting to add.  Given a world of ssh
connections I expect a persuasive case can be made.  Especially if there
are a handful of utilities where it is already implemented that just
need to be built with SIGINFO defined.

>  - Add BSD SIGINFO (and VSTATUS) as a test.

If your actual point is not to implement SIGINFO and you really have
another use case for expanding sigset_t please make it clear.

Without seeing the persuasive case for more signals I have to say that
adding more signals to the kernel sounds like a bad idea.

Eric




