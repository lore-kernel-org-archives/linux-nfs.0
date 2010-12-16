Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:52376 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756116Ab0LPPWp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 10:22:45 -0500
Received: by bwz16 with SMTP id 16so3684296bwz.4
        for <linux-nfs@vger.kernel.org>; Thu, 16 Dec 2010 07:22:44 -0800 (PST)
Date: Thu, 16 Dec 2010 10:22:43 -0500
Message-ID: <AANLkTinKSm0Hvq9K2dbguyRfmZdPFJJsSNk+oY0Wo9pv@mail.gmail.com>
Subject: layoutcommits and file layout
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(Adding nfsv4@ietf, where this discussion belongs)

On Thu, Dec 16, 2010 at 9:49 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 12/16/2010 04:13 PM, Fred Isaman wrote:
>> On Thu, Dec 16, 2010 at 7:47 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> On 12/10/2010 03:22 AM, Fred Isaman wrote:
>>>> Since file does not need them, just turn them off for
>>>> the moment.  Non-file layouts will probably have to trigger them in
>>>> some fashion at close.
>>>>
>>>
>>> Rrrr. Are we back to this argument. We stand down win an argument
>>> and 2 weeks later you are back on it has if we never talked about it.
>>>
>>> NO!!! only "coherent clustered filesystems" do not need them. It has
>>> nothing to do with layout type. A none-clustered aggregated parallel
>>> filesystem will need them just the same as blocks and objects.
>>>
>>> AND THE STD DOES NOT GIVE YOU A CHOICE!!!
>>
>> You keep saying this, but just repeating it does not convince me.
>> Could you please take the time to explain *why* they are needed.  A
>> separate thread in the ietf list would be great.  Because right now,
>> Andy and I are coding and preparing for submission to Trond under the
>> assumption that they are possibly a nice optimization, but are never
>> actually needed for the file layout.
>>
>> Fred
>>
>
> I have many times. You are being forgetful. Last bakeathon Mike, I think
> or someone, had a proposition talk that "since layoutcommit is use less,
> lets make it optional". And we went into a long argument about that. Until
> finally Trond came to the rescue and explained very clearly. Better then
> I ever could, that if you want to keep current reboot semantics a client
> must send a successful layoutcommit after all successful DS commits before
> it can free it's dirty pages. layoutcommit is the writing of meta data after
> the write of data, and is, just as important, a part of a file.
>

More recent discussions I've had with Trond lead me to believe he no
longer holds this opinion.  Hopefully he can clarify.

> Consider an spNFS type filesystem that keeps all meta-data on MDS and
> the data on disjoint independent DSs. None of the servers see the same
> data and the MDS is just another client + Meta information. layoutcommit
> is the point data is exposed outside and also the point meta-data is persisted
> (Somewhere). Failing to do layoutcommits will not enable me to do such
> simple, scalable and possibly reliable FSs. The authors of the STD did
> envision such systems and invented the layoutcommit. (There is the issue of
> the changed_attribute of a crashing writing client but this is solvable with
> very simple MDS-to-DS communication, and is another matter)
>

I am relying on the text from errata 2505, which states that the MDS
MUST have a means of synchronizing with the data servers.  Given that,
where in your above fs is the LAYOUTCOMMIT *needed*, as opposed to
being just a very helpful optimization?

Fred

> The fact that we had the above talk also proves another thing. That the
> STD does not make layoutcommit optional, hence the request to make it
> optional.
>
> And nothing of the above is new. I have stated that many times and
> you keep "forgetting".
>
> BTW: An object based filesystem could be implemented just as well
> over files as over objects. Save the RAID5 stuff. Objects being
> partition/objectid numeric file names, and uid/gid games for fencing
> off / access permission. In such a system layoutcommits serve the
> same purpose as in objects, but with a files layout
>
> You can call me and we can talk about it if you need to. But do
> You agree that the current STD text mandates it?
>
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
