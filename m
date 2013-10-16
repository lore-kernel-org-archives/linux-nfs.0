Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932406Ab3JPMVz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 08:21:55 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9GCLsRY020179
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 16 Oct 2013 08:21:54 -0400
Message-ID: <525E850B.5090700@RedHat.com>
Date: Wed, 16 Oct 2013 08:22:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: ssorce@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/2] gssd: allow gssd to work with KEYRING: credcaches
References: <1381350116-10464-1-git-send-email-jlayton@redhat.com> <20131015093419.789e4d2a@tlielax.poochiereds.net>
In-Reply-To: <20131015093419.789e4d2a@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 15/10/13 09:34, Jeff Layton wrote:
> On Wed,  9 Oct 2013 16:21:54 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> Changes since original set:
>> v3:
>> - have parent check to see if child was signalled and log a warning if so
>> - drop supplimentary groups and change gid before acquiring creds. Keep
>>   suid and sgid as well to hamper ptrace.
>>
>> v2:
>> - fix bisectability. The original set added includes in the wrong
>>   place in patch #1 and then fixed it in patch #2. The final result
>>   of this set is the same but should bisect cleanly.
>>
>> This patchset fixes up gssd to work with KEYRING: style credcaches. At
>> the same time, it also fixes gssd not to need to trawl through likely
>> credcache locations by allowing GSSAPI to find them in the intended
>> fashion.
>>
>> The basic idea is to have gssd fork() after reading off the pipe, but
>> before handling the upcall and to do a more thorough job of changing
>> credentials.
>>
>> Jeff Layton (2):
>>   gssd: have process_krb5_upcall fork before handling upcall
>>   gssd: do a more thorough change of identity after forking
>>
>>  utils/gssd/gssd_proc.c | 106 +++++++++++++++++++++++++++++++++++++++++--------
>>  1 file changed, 89 insertions(+), 17 deletions(-)
>>
> 
> I had asked Steve to hold off on applying these until now. While they
> work as expected for the most part, they break a the case where gssd is
> set up to use gssproxy to get credentials. Older versions of gssproxy
> relied on the caller having and euid of 0. Simo now has a set of fixes
> queued up for gssproxy to address the problem, so the way should now be
> clear to merge this set into nfs-utils.
> 
> One thing we will probably want to do for Fedora at least is to add a
> "Conflicts:" with older versions of gssproxy. That should ensure that
> people relying on gssd + gssproxy won't get any surprises when updating.
> 
> Steve, sound reasonable?
I'll queue them up...

steved.

> 
