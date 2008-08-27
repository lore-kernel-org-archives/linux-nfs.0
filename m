From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: RESTRICTED_STATD
Date: Wed, 27 Aug 2008 10:14:06 -0400
Message-ID: <76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
	 <48B5332B.2040800@RedHat.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:13807 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbYH0OOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 10:14:09 -0400
Received: by gv-out-0910.google.com with SMTP id e6so474847gvc.37
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2008 07:14:06 -0700 (PDT)
In-Reply-To: <48B5332B.2040800-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2008 at 6:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> Chuck Lever wrote:
>> Hi guys-
>>
>> I was wondering if anyone ever builds nfs-utils with RESTRICTED_STATD
>> undefined these days.  It seems totally insecure to do.  Is it still
>> necessary to keep this?
>>
>> It would be easier to understand, update, and test the logic in
>> utils/statd/monitor.c (IPv6-wise) if we could remove the unused parts of
>> this code.
>>
>> I propose removing RESTRICTED_STATD, leaving in the secure version of
>> the code permanently and removing the insecure parts that are left out
>> when RESTRICTED_STATD is undefined.
>>
>> Thoughts?
> I seem to remember enabling RESTRICTED_STATD cause problems with
> portmapper and kernel interactions which causes me to turn it off...
> So if we do permanently turn on the code, let make sure lock recover
> and such still work...

Enabling RESTRICTED_STATD is the current default.

Disabling RESTRICTED_STATD allows remote hosts to register
notification requests with rpc.statd.  It's called out in a 1999 CERT
advisory.  I don't think any distribution would ever want to allow
this.

However, there may be some folks who build rpc.statd themselves for
specialized applications may miss it if we pull it out.

-- 
"If you simplify your English, you are freed from the worst follies of
orthodoxy."
 -- George Orwell
