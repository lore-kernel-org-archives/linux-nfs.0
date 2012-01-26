Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735Ab2AZVuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:50:22 -0500
Message-ID: <4F21CA97.3020906@RedHat.com>
Date: Thu, 26 Jan 2012 16:50:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpc.gssd: Links directly with libgssapi_krb5 which not
 needed.
References: <1327608461-15305-1-git-send-email-steved@redhat.com> <20120126203006.GD31531@fieldses.org>
In-Reply-To: <20120126203006.GD31531@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2012 03:30 PM, J. Bruce Fields wrote:
> On Thu, Jan 26, 2012 at 03:07:41PM -0500, Steve Dickson wrote:
>> rpc.gssd and rpc.svcgssd both link with the libgssapi_krb5 and
>> libgssglue libraries which is not needed since libgssglue
>> will dynamically load the gssapi interface defined in the
>> /etc/gssapi_mech.conf. Most likely the libgssapi_krb5 library.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  aclocal/kerberos5.m4 |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
>> index dfa5738..7574e2d 100644
>> --- a/aclocal/kerberos5.m4
>> +++ b/aclocal/kerberos5.m4
>> @@ -31,7 +31,7 @@ AC_DEFUN([AC_KERBEROS_V5],[
>>      fi
>>      if test "$K5CONFIG" != ""; then
>>        KRBCFLAGS=`$K5CONFIG --cflags`
>> -      KRBLIBS=`$K5CONFIG --libs gssapi`
>> +      KRBLIBS=`$K5CONFIG --libs`
> 
> OK, so that's gathering krb5-config output which gives us the list of -l
> switches we need to link in kerberos libraries, and removing the
> "gssapi" argument has the effect of removing "-lgssapi_krb5" from the
> output.
Right...

> 
> Ack, I guess, except: I'm a little confused why we want to link with
> *any* kerberos libraries, if rpc.gssd and rpc.svcgssd are supposed to
> themselves be completely mechanism-independent and are supposed to
> dlopen() aything they need for kerberos.
Well when they are not liked with any kerberos libs the following
are undefined http://fpaste.org/rWOR/

I'm treading on a thin ice here but I'm thinking those undefines are
not part the gssapi. Only the gssapi routines are dynamically linked.

Thanks for the time!

steved.
