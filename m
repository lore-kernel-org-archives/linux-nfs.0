Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp07.online.nl ([194.134.42.52]:47981 "EHLO smtp07.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525Ab1CRNyO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Mar 2011 09:54:14 -0400
Received: from smtp07.online.nl (localhost [127.0.0.1])
	by smtp07.online.nl (Postfix) with ESMTP id 8C7B59803A
	for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2011 14:54:12 +0100 (CET)
Received: from srv1.net.home (s5375c22f.adsl.wanadoo.nl [83.117.194.47])
	by smtp07.online.nl (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2011 14:54:11 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by srv1.net.home (Postfix) with ESMTP id 8180E8044C
	for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2011 14:54:11 +0100 (CET)
Received: from srv1.net.home ([127.0.0.1])
	by localhost (webmail.net.home [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 0tIEgjzcNrIT for <linux-nfs@vger.kernel.org>;
	Fri, 18 Mar 2011 14:54:11 +0100 (CET)
Received: from localhost (unknown [192.168.1.216])
	by srv1.net.home (Postfix) with ESMTP id EE765802F4
	for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2011 14:54:10 +0100 (CET)
Message-ID: <20110318145410.45566wbpd0zpt536@vovan.nl>
Date: Fri, 18 Mar 2011 14:54:10 +0100
From: Vladimir Elisseev <vovan@vovan.nl>
To: linux-nfs@vger.kernel.org
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
References: <1300387690.2684.23.camel@vovan.net.home>
 <AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>
 <1300427036.30472.11.camel@vovan.net.home>
 <AANLkTim7q+-ijBnzWs+zW9X-gfxyrt5kw4Vj_pcrWJFw@mail.gmail.com>
In-Reply-To: <AANLkTim7q+-ijBnzWs+zW9X-gfxyrt5kw4Vj_pcrWJFw@mail.gmail.com>
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kevin,

Sorry, I have to mention this initially: the server has nfs-utils
1.2.3, but clients have 1.2.2 (we've tested and upgraded servers
firstly without having any problems). As for the rest, see my comment
in-line below.

Regards,
Vladimir.

Quoting Kevin Coffman <kwc@citi.umich.edu>:

> Vladimir,
> Having the raw crypto enabled in the kernel is only part of it.  The
> RPC GSS support to make use of it went into 2.6.35, so your server's
> kernel should have that.
Thanks for clarifying this.

>
> Did the output from svcgssd change when you added the
> default_tgs_enctypes?  Specifically, "prepare_krb5_rfc4121_buffer:
> serializing key with enctype 18 and size 32" should have changed to a
> different enctype and size.
After changing krb5.conf I saw the same entry "repare_krb5_rfc4121_buffer:
serializing key with enctype 18 and size 32" in the log file. However,
I think I had to restart rpc.svcgssd (is this true?), but I didn't.
Unfortunately, changing default_tgs_enctypes for Kerberos will have
global effect and can be used only for testing purposes.

>
> If adding default_tgs_enctypes didn't help, the patches dealing with
> "acceptor subkey" won't help.
>
> Does the server continue to work for other clients?
As I mentioned at the beginning of this mail, clients with nfs-utils
1.2.2 work just fine and are able use des encryption:
klist -ce /tmp/krb5cc_machine_X.X
Ticket cache: FILE:/tmp/krb5cc_machine_X.X
Default principal: host/x.x.x@X.X

Valid starting     Expires            Service principal
03/18/11 06:40:36  03/19/11 06:40:36  krbtgt/X.X@X.X
          Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96
03/18/11 06:40:37  03/19/11 06:40:36  nfs/nfs.x.x@X.X
          Etype (skey, tkt): des-cbc-crc, aes256-cts-hmac-sha1-96

> K.C.
>
> On Fri, Mar 18, 2011 at 1:43 AM, Vladimir Elisseev <vovan@vovan.nl> wrote:
>> Kevin,
>>
>> I think the kernel configuration on server include AES encryption:
>> zcat /proc/config.gz| grep -i aes
>> CONFIG_CRYPTO_AES=y
>> CONFIG_CRYPTO_AES_X86_64=y
>> # CONFIG_CRYPTO_AES_NI_INTEL is not set
>> IMO, this is sufficient. As for the kerberos version on the client it's
>> 1.9 with patches: CVE-2010-4022, CVE-2011-0281,0282,0283,0284.
>> Changing server's krb5.conf with default_tgs_enctypes = des-cbc-crc
>> doesn't solve this problem.
>> As you suggested I'm going to check patches regarding "acceptor subkey".
>>
>> Regards,
>> Vladimir.
>>
>> On Thu, 2011-03-17 at 18:13 -0400, Kevin Coffman wrote:
>>> On Thu, Mar 17, 2011 at 2:48 PM, Vladimir Elisseev <vovan@vovan.nl> wrote:
>>> > Hello,
>>> >
>>> > I've got a problem after updating NFS client. I've been trying to find
>>> > possible solution without a success for a while, so I'd appreciate any
>>> > help. All the info is below. Client has kernel 2.6.37 and server 2.6.36.
>>> >
>>> > Regards,
>>> > Vladimir.
>>> >
>>> > On the server side the error is "rpc.svcgssd[15159]: qword_eol: fflush
>>> > failed: errno 22 (Invalid argument)", the full track is below:
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: leaving poll
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: handling null request
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: sname = host/x.x.x@X.X
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
>>> > umich_ldap->princ_to_ids
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: ldap_init_and_bind: version
>>> > mismatch between API information and protocol version. Setting protocol
>>> > version to 3
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
>>> > umich_ldap->princ_to_ids returned -2
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
>>> > nsswitch->princ_to_ids
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nss_getpwnam: name
>>> > 'host/x.x.x@X.X' domain '(null)': resulting localname
>>> > 'host/user.net.home'
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
>>> > nsswitch->princ_to_ids returned -2
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: final
>>> > return value is -2
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: DEBUG: serialize_krb5_ctx:
>>> > lucid version!
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
>>> > protocol 1
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
>>> > serializing key with enctype 18 and size 32
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: doing downcall
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: mech: krb5, hndl len: 4, ctx
>>> > len 52, timeout: 1300464362 (86399 from now), clnt: host@x.x.x, uid: -1,
>>> > gid: -1, num aux grps: 0:
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: qword_eol: fflush failed: errno
>>> > 22 (Invalid argument)
>>> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: WARNING: error writing to
>>> > downcall channel /proc/net/rpc/auth.rpcsec.context/channel: Invalid
>>> > argument
>>>
>>> I've seen this when the negotiated enctype is AES (18), and the kernel
>>> does not have AES support.  However, 2.6.36 should have AES support.
>>> Did the client update include a Kerberos version update as well?  (See
>>> recently submitted patches regarding "acceptor subkey".)
>>>
>>> The immediate work-around for the acceptor subkey problem is to set
>>>
>>>   default_tgs_enctypes = des-cbc-crc
>>>
>>> in the server's /etc/krb5.conf file.  Could you try this and see  
>>> if it helps?
>>>
>>> K.C.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>




