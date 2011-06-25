Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48675 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab1FYOya convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2011 10:54:30 -0400
Received: by iwn6 with SMTP id 6so3072049iwn.19
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2011 07:54:29 -0700 (PDT)
In-Reply-To: <4E04F7E1.2080708@indiana.edu>
References: <4E00A214.2060306@indiana.edu>
	<4E01F1A4.4080204@RedHat.com>
	<4E04F7E1.2080708@indiana.edu>
Date: Sat, 25 Jun 2011 10:54:26 -0400
Message-ID: <BANLkTimepAUNrbbexzOaZEvDtLGCWsKtpg@mail.gmail.com>
Subject: Re: NFSv4 plus Kerberos with RHEL5 servers and RHEL6 clients using a
 Windows KDC (SOLVED)
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Rob Henderson <robh@indiana.edu>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Windows KDC doesnt like creating des keys and it has to be enabled
specifically. So what happened is that while you created your NFS
server keytab with a des key, your user's enctypes are windows
defaults which is arcfour-hmac. Btw, if you want des tickets for user,
then all user accounts in AD should be configured with an option "use
DES encryption methods".

Also let's remember that there are default_tkt_enctype and
default_tgs_enctype. First one limits encryption types for a tgt and
another is for a service ticket. In this scenario, your tgts should be
either arcfour or aes and your nfs service ticket should be des.

On Fri, Jun 24, 2011 at 4:47 PM, Rob Henderson <robh@indiana.edu> wrote:
> When I try the settings you suggest, the mount is actually successful.  However, when I login as a normal user and try to obtain a tgt I see the following:
>
>  $ kinit
>  kinit: KDC has no support for encryption type while getting initial credentials
>
> As soon as I add arcfour-hmac to default_tgs_enctypes the kinit then works.  However, it doesn't appear that nfs actually work properly until I add both es256-cts-hmac-sha1-96 and arcfour-hmac to this list, tho I haven't tested that extensively.
>
>  --Rob
>
>
> Steve Dickson wrote:
>> Hey Rob,
>>
>> Thanks for the info... I was thought the correct default enctypes
>> for Window KDCs where
>>     default_tgs_enctypes = des-cbc-md5
>>     default_tkt_enctypes = des-cbc-md5
>>
>> Maybe we should add this finding to the the NFS FAQ (http://nfs.sourceforge.net/) ?
>>
>> steved.
>>
>> On 06/21/2011 09:52 AM, Rob Henderson wrote:
>>> We had trouble getting kerberized nfsv4 working in our environment with RHEL5 servers and RHEL6 clients using the campus Windows 2008 AD servers as our KDC.  We've resolved the issue now but I just wanted to summarize our solution in case others are fighting the same problem.
>>>
>>> The key issue seems related to encryption since 1) the older RHEL5 kernels only support DES for nfs and 2) it appears that limiting the keytabs to only DES causes a failure to communicate with our campus Windows KDC.  I found a number of discussions that suggested limiting the encryption types to only DES and this seems to be the common fix when using a standard MIT kerberos server.  However, in our environment we are using a Windows KDC and that solution did not work for us.  I don't know if that is a generic problem with a Windows KDC or something particular to the configuration of our campus servers.
>>>
>>> Cutting to the chase, here is the configuration in the /etc/krb5.conf on the RHEL6 client that worked for us:
>>>
>>>     [libdefaults]
>>>         default_tkt_enctypes = des-cbc-crc aes256-cts-hmac-sha1-96 arcfour-hmac
>>>         allow_weak_crypto = 1
>>>
>>>
>>> All the gory details are below for anyone interested.
>>>
>>>    --Rob
>>>
>>> Disclaimer:  I am not saying this is the only and/or best solution, but it is working for us... :)
>>>
>>> ===================================================================
>>>
>>>
>>> Keytab Generation
>>> =================
>>>
>>> The campus Windows AD admins generate nfs keytabs for us using the "/crypto ALL" argument to ktpass.  They also set the NO_AUTH_DATA_REQUIRED UAC flag on the associated machine accounts.  Keytabs are generated using the same procedure for both servers and clients.
>>>
>>>
>>> RHEL5 NFS Server
>>> ================
>>>
>>> The keytabs are installed on the RHEL5 server and look like this:
>>>
>>> # klist -kte
>>>
>>> Keytab name: FILE:/etc/krb5.keytab
>>> KVNO Timestamp         Principal
>>> ---- ----------------- --------------------------------------------------------
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (DES cbc mode with CRC-32)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (DES cbc mode with RSA-MD5)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (ArcFour with HMAC/md5)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (AES-256 CTS mode with 96-bit SHA-1 HMAC)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (AES-128 CTS mode with 96-bit SHA-1 HMAC)
>>>
>>> There is nothing special in the /etc/krb5.conf on the server side.
>>>
>>>
>>> RHEL6 NFS Client
>>> ================
>>>
>>> The keytabs for the client are generated in the same way as for the server and look exactly like that for the server (with the exception that the encryption types are displayed differently with the newer version of klist).  They look like this:
>>>
>>> # klist -kte
>>> Keytab name: WRFILE:/etc/krb5.keytab
>>> KVNO Timestamp         Principal
>>> ---- ----------------- --------------------------------------------------------
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (des-cbc-crc)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (des-cbc-md5)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (arcfour-hmac)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (aes256-cts-hmac-sha1-96)
>>>    3 12/31/69 19:00:00 nfs/[hostname]@[REALM] (aes128-cts-hmac-sha1-96)
>>>
>>>
>>> The following are added to the /etc/krb5.conf:
>>>
>>>      [libdefaults]
>>>         default_tkt_enctypes = des-cbc-crc aes256-cts-hmac-sha1-96 arcfour-hmac
>>>         allow_weak_crypto = 1
>>>
>>> After the mount, the machine credentials on the client look like this:
>>>
>>>       # klist -e /tmp/krb5cc_machine_[REALM]
>>>       Ticket cache: FILE:/tmp/krb5cc_machine_[REALM]
>>>       Default principal: nfs/[client hostname]@[REALM]
>>>
>>>       Valid starting     Expires            Service principal
>>>       06/21/11 02:44:18  06/21/11 12:44:18  krbtgt/[REALM]@[REALM]
>>>               renew until 06/28/11 02:44:18, Etype (skey, tkt): des-cbc-crc, aes256-cts-hmac-sha1-96
>>>       06/21/11 02:44:18  06/21/11 12:44:18  nfs/[server hostname]@[REALM]
>>>               renew until 06/28/11 02:44:18, Etype (skey, tkt): des-cbc-crc, aes256-cts-hmac-sha1-96
>>>
>>> And, the user sees the following:
>>>
>>>       $ klist -e
>>>       Ticket cache: FILE:/tmp/krb5cc_[UID]_EfGvpD
>>>       Default principal: [USERNAME]@[REALM]
>>>
>>>       Valid starting     Expires            Service principal
>>>       06/21/11 09:33:01  06/21/11 19:33:01  krbtgt/[REALM]@[REALM]
>>>               renew until 06/28/11 09:33:01, Etype (skey, tkt): des-cbc-crc, aes256-cts-hmac-sha1-96
>>>       06/21/11 09:33:03  06/21/11 19:33:01  nfs/[server hostname]@[REALM]
>>>              renew until 06/28/11 09:33:01, Etype (skey, tkt): des-cbc-crc, aes256-cts-hmac-sha1-96
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
