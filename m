Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:34973 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425Ab2AZWiY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 17:38:24 -0500
Received: by obcva7 with SMTP id va7so1067168obc.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2012 14:38:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F21CA97.3020906@RedHat.com>
References: <1327608461-15305-1-git-send-email-steved@redhat.com>
	<20120126203006.GD31531@fieldses.org>
	<4F21CA97.3020906@RedHat.com>
Date: Thu, 26 Jan 2012 17:38:23 -0500
Message-ID: <CAKnQG+cQpGwJng22cB8BQ8x_j9VhwDE94xj=1xezjvpp6MsVEg@mail.gmail.com>
Subject: Re: [PATCH] rpc.gssd: Links directly with libgssapi_krb5 which not needed.
From: Kevin Coffman <kwc@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 26, 2012 at 4:50 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 01/26/2012 03:30 PM, J. Bruce Fields wrote:
>> On Thu, Jan 26, 2012 at 03:07:41PM -0500, Steve Dickson wrote:
>>> rpc.gssd and rpc.svcgssd both link with the libgssapi_krb5 and
>>> libgssglue libraries which is not needed since libgssglue
>>> will dynamically load the gssapi interface defined in the
>>> /etc/gssapi_mech.conf. Most likely the libgssapi_krb5 library.
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  aclocal/kerberos5.m4 |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
>>> index dfa5738..7574e2d 100644
>>> --- a/aclocal/kerberos5.m4
>>> +++ b/aclocal/kerberos5.m4
>>> @@ -31,7 +31,7 @@ AC_DEFUN([AC_KERBEROS_V5],[
>>>      fi
>>>      if test "$K5CONFIG" != ""; then
>>>        KRBCFLAGS=`$K5CONFIG --cflags`
>>> -      KRBLIBS=`$K5CONFIG --libs gssapi`
>>> +      KRBLIBS=`$K5CONFIG --libs`
>>
>> OK, so that's gathering krb5-config output which gives us the list of -l
>> switches we need to link in kerberos libraries, and removing the
>> "gssapi" argument has the effect of removing "-lgssapi_krb5" from the
>> output.
> Right...
>
>>
>> Ack, I guess, except: I'm a little confused why we want to link with
>> *any* kerberos libraries, if rpc.gssd and rpc.svcgssd are supposed to
>> themselves be completely mechanism-independent and are supposed to
>> dlopen() aything they need for kerberos.
> Well when they are not liked with any kerberos libs the following
> are undefined http://fpaste.org/rWOR/
>
> I'm treading on a thin ice here but I'm thinking those undefines are
> not part the gssapi. Only the gssapi routines are dynamically linked.
>
> Thanks for the time!

Most of those functions are dealing with finding credentials caches
and keytabs and examining them.  (Trying to pick the right credential
cache to use, and trying to find the right keytab entry to use...)  As
Steve said, those are strictly Kerberos functions, not GSSAPI.

K.C.
