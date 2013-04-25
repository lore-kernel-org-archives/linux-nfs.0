Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm26.access.bullet.mail.sp2.yahoo.com ([98.139.44.153]:29189
	"EHLO nm26.access.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758719Ab3DYB1W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 21:27:22 -0400
Message-ID: <5178867E.30704@schaufler-ca.com>
Date: Wed, 24 Apr 2013 18:27:26 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, eparis@redhat.com,
        sds@tycho.nsa.gov, Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 04/17] Security: Add hook to calculate context based on
 a negative dentry.
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com> <1366834683-29075-5-git-send-email-SteveD@redhat.com> <20130424220258.GO20275@fieldses.org> <517858D1.5000406@RedHat.com> <faf7db0bcd9b208c201a652c718c720c@countercultured.net> <20130424230312.GS20275@fieldses.org> <dece1c7129e6927e9a92d38879818a46@countercultured.net>
In-Reply-To: <dece1c7129e6927e9a92d38879818a46@countercultured.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/24/2013 4:05 PM, David Quigley wrote:
> On 04/24/2013 19:03, J. Bruce Fields wrote:
>> On Wed, Apr 24, 2013 at 06:14:16PM -0400, David Quigley wrote:
>>> On 04/24/2013 18:12, Steve Dickson wrote:
>>> >On 24/04/13 18:02, J. Bruce Fields wrote:
>>> >>n Wed, Apr 24, 2013 at 04:17:50PM -0400, Steve Dickson wrote:
>>> >>>> From: David Quigley <dpquigl@davequigley.com>
>>> >>>>
>>> >>>> There is a time where we need to calculate a context without the
>>> >>>> inode having been created yet. To do this we take the
>>> >>>negative dentry and
>>> >>>> calculate a context based on the process and the parent
>>> >>>directory contexts.
>>> >>How can we get review from security/selinux folks?  I can't
>>> >>apply these
>>> >>without....
>>> >Its my understand they have been reviewed a number times... And
>>> >they have not
>>> >change since I've working on these patches...
>>> >
>>> >steved.
>>> >--
>>> >To unsubscribe from this list: send the line "unsubscribe
>>> >linux-nfs" in
>>> >the body of a message to majordomo@vger.kernel.org
>>> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> That is correct. They have been acked in the past and haven't
>>> changed at all since then.

For the record, I haven't ACKed because I have been unable to
get the NFS labeling to work with Smack. I also note that I
am not NAKing, either, as I have not had the time to determine
what's wrong. I do know that the ideas floated at the time turned
out to not be the problem. Hopefully I'll have time to look
into this sometime.


>>
>> Oh, OK, sorry--I lost track.  (Do you have a pointer?)
>
> I may be able to crawl through MARC.info for my old email address to
> see if I can find it but that is probably more effort than its worth.
> All of those ACKs and what not are saved in my old NSA email (assuming
> its still being kept around).
>
>>
>>> I have contacted Eric Paris about
>>> reviewing them anyway so you can have a more recent ack on the
>>> patches.
>>
>> But that would be helpful too, thanks.
>>
>> --b.
>
>
> I think its a good idea to have Eric look through them anyway just to
> be sure.
>
> Dave
>
> -- 
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to
> majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.
>

