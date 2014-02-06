Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:51845 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbaBFSwQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 13:52:16 -0500
Received: by mail-oa0-f45.google.com with SMTP id i11so2871014oag.32
        for <linux-nfs@vger.kernel.org>; Thu, 06 Feb 2014 10:52:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140206183631.GA30952@fieldses.org>
References: <CAPCnwUeUEznrKvJ-upUV_VyaKKhZcKpZbLFeC08YMMQycWK-vg@mail.gmail.com>
	<CAPCnwUeobfXKGB9Q-nyYNDZa1L9iTwoKZm9bBH2ghUkqembCeA@mail.gmail.com>
	<20140206183631.GA30952@fieldses.org>
Date: Thu, 6 Feb 2014 13:52:16 -0500
Message-ID: <CAPCnwUcXaGUMs1r23+oPROzPQpmgLV62zGBZE6dbt0nvF75=DQ@mail.gmail.com>
Subject: Re: Windows AD, Users with too many groups
From: Norman Elton <normelton@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> And they have that same group membership on the server side?

Yes, both the NFS server and NFS client point to the same active
directory for ldap / kerberos.

I have tried running rpc.svcgssd with debugging, as well as with
strace as you suggested. I get plenty of output when a "good" user
logs in. No debugging information for user who fails. The error
(failed to create krb5 context...) appears on the client, maybe before
it connects to the server?

Thanks,

Norman

On Thu, Feb 6, 2014 at 1:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Feb 06, 2014 at 01:19:19PM -0500, Norman Elton wrote:
>> Just a follow-up to my previous post. In debugging rpc.gssd on the
>> client, here's where things are dying:
>>
>> creating tcp client for server filertest.safety.net.wm.edu
>> creating context with server nfs@filertest.safety.net.wm.edu
>> WARNING: Failed to create krb5 context for user with uid 30487 for
>> server filertest.safety.net.wm.edu
>>
>> But other users seem fine. I still think it's something to do with
>> excessive group membership.
>
> And they have that same group membership on the server side?
>
> In that case there might be some problem with rpc.svcgssd's handling of
> large group lists--some debugging of rpc.svcgssd on the server might be
> interesting.
>
> In particular, output from:
>
>         strace -p $(pidof rpc.svcgssd) -s65536 -e trace=open,close,read,write
>
> might be interesting.
>
> --b.
>
>>
>> Any suggestions are appreciated, thanks!
>>
>> Norman Elton
>> College of William & Mary
>>
>> On Mon, Feb 3, 2014 at 4:13 PM, Norman Elton <normelton@gmail.com> wrote:
>> > I've read stories about users having too many group memberships. We
>> > seem to experience similar symptoms, though the usual tricks don't
>> > seem to work.
>> >
>> > In our case, there is a RHEL6 NFS server feeding multiple RHEL6 NFS
>> > clients. This is all NFSv4 with Kerberos. Most users can login fine,
>> > but domain admins get a "permission denied" when accessing their
>> > NFS-mounted home directory. The most notable commonality is their high
>> > number of group memberships.
>> >
>> > I've tried inflating my group count to greater than 16, my account
>> > continues to work fine.
>> >
>> > We've tried adding "--manage-gids" to rpc.mountd, no luck. Although
>> > it's unclear whether this really does anything in a kerberized
>> > environment.
>> >
>> > Any other suggestions? Other debugging tricks?
>> >
>> > Thanks
>> >
>> > Norman Elton
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
