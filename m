Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f41.google.com ([209.85.219.41]:50278 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbaBFTpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 14:45:40 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so2967536oag.28
        for <linux-nfs@vger.kernel.org>; Thu, 06 Feb 2014 11:45:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140206185843.GA31325@fieldses.org>
References: <CAPCnwUeUEznrKvJ-upUV_VyaKKhZcKpZbLFeC08YMMQycWK-vg@mail.gmail.com>
	<CAPCnwUeobfXKGB9Q-nyYNDZa1L9iTwoKZm9bBH2ghUkqembCeA@mail.gmail.com>
	<20140206183631.GA30952@fieldses.org>
	<CAPCnwUcXaGUMs1r23+oPROzPQpmgLV62zGBZE6dbt0nvF75=DQ@mail.gmail.com>
	<20140206185843.GA31325@fieldses.org>
Date: Thu, 6 Feb 2014 14:45:39 -0500
Message-ID: <CAPCnwUcL6-2yciiDvYiVuWrF8_V3h9551hCThCO94yVX9JHSPA@mail.gmail.com>
Subject: Re: Windows AD, Users with too many groups
From: Norman Elton <normelton@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> OK, must be.  You could also confirm this by looking at network traffic,
>> e.g. with wireshark.

We do see NFS traffic between the client and the server, but I cannot
get any useful debug information when a failing user logs in. I've got
rpc.svcgssd, rpc.idmapd, and rpc.mountd all running with the relevant
-d's and -v's.

I do see kerberos traffic, and indeed both good and failing users are
getting kerb tickets. I've compared all the list outputs I can
generate, and don't see any obvious differences. In look at packet
captures between the client and KDC, I've noticed one difference. The
client requests a TGT in a AS-REQ packet. The KDC responds with a
AS-REP. This AS-REP has a krbtgt/DOMAIN ticket in it, followed by some
additional data (my kerb protocol kung-fu is weak here). This last
data has "kvno: 4", so perhaps it's some sort of key? In any case, on
the failing user, this is listed with enctype rc4-hmac, on the passing
user, it's enctype aes256-cts-hmac-sha1-96.

Thanks again for your advice,

Norman

On Thu, Feb 6, 2014 at 1:58 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Feb 06, 2014 at 01:52:16PM -0500, Norman Elton wrote:
>> > And they have that same group membership on the server side?
>>
>> Yes, both the NFS server and NFS client point to the same active
>> directory for ldap / kerberos.
>>
>> I have tried running rpc.svcgssd with debugging, as well as with
>> strace as you suggested. I get plenty of output when a "good" user
>> logs in. No debugging information for user who fails. The error
>> (failed to create krb5 context...) appears on the client, maybe before
>> it connects to the server?
>
> OK, must be.  You could also confirm this by looking at network traffic,
> e.g. with wireshark.
>
> Might also be worth looking at the client<->KDC traffic to see if the
> client is getting as far as asking for a ticket and if so what error the
> KDC is returning.
>
> --b.
>
>>
>> Thanks,
>>
>> Norman
>>
>> On Thu, Feb 6, 2014 at 1:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Thu, Feb 06, 2014 at 01:19:19PM -0500, Norman Elton wrote:
>> >> Just a follow-up to my previous post. In debugging rpc.gssd on the
>> >> client, here's where things are dying:
>> >>
>> >> creating tcp client for server filertest.safety.net.wm.edu
>> >> creating context with server nfs@filertest.safety.net.wm.edu
>> >> WARNING: Failed to create krb5 context for user with uid 30487 for
>> >> server filertest.safety.net.wm.edu
>> >>
>> >> But other users seem fine. I still think it's something to do with
>> >> excessive group membership.
>> >
>> > And they have that same group membership on the server side?
>> >
>> > In that case there might be some problem with rpc.svcgssd's handling of
>> > large group lists--some debugging of rpc.svcgssd on the server might be
>> > interesting.
>> >
>> > In particular, output from:
>> >
>> >         strace -p $(pidof rpc.svcgssd) -s65536 -e trace=open,close,read,write
>> >
>> > might be interesting.
>> >
>> > --b.
>> >
>> >>
>> >> Any suggestions are appreciated, thanks!
>> >>
>> >> Norman Elton
>> >> College of William & Mary
>> >>
>> >> On Mon, Feb 3, 2014 at 4:13 PM, Norman Elton <normelton@gmail.com> wrote:
>> >> > I've read stories about users having too many group memberships. We
>> >> > seem to experience similar symptoms, though the usual tricks don't
>> >> > seem to work.
>> >> >
>> >> > In our case, there is a RHEL6 NFS server feeding multiple RHEL6 NFS
>> >> > clients. This is all NFSv4 with Kerberos. Most users can login fine,
>> >> > but domain admins get a "permission denied" when accessing their
>> >> > NFS-mounted home directory. The most notable commonality is their high
>> >> > number of group memberships.
>> >> >
>> >> > I've tried inflating my group count to greater than 16, my account
>> >> > continues to work fine.
>> >> >
>> >> > We've tried adding "--manage-gids" to rpc.mountd, no luck. Although
>> >> > it's unclear whether this really does anything in a kerberized
>> >> > environment.
>> >> >
>> >> > Any other suggestions? Other debugging tricks?
>> >> >
>> >> > Thanks
>> >> >
>> >> > Norman Elton
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
