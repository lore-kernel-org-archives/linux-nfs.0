From: Luke Cyca <luke-rgTVnuQaENGakBO8gow8eQ@public.gmane.org>
Subject: NFS+krb5: Failed to create krb5 context for user with uid 0
Date: Tue, 5 Feb 2008 17:51:06 -0800
Message-ID: <1459814D-D960-44A2-947E-F6D0BD46DAC6@zymeworks.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from s216-232-71-140.bc.hsia.telus.net ([216.232.71.140]:52828 "EHLO
	mail.zymeworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763614AbYBFCTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 21:19:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.zymeworks.com (Postfix) with ESMTP id 4268EDA0787
	for <linux-nfs@vger.kernel.org>; Tue,  5 Feb 2008 17:51:10 -0800 (PST)
Received: from mail.zymeworks.com ([127.0.0.1])
 by localhost (bartender.lan.zymeworks.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 00788-10 for <linux-nfs@vger.kernel.org>;
 Tue,  5 Feb 2008 17:51:06 -0800 (PST)
Received: from [192.168.1.25] (moonshine.lan.zymeworks.com [192.168.1.25])
	by mail.zymeworks.com (Postfix) with ESMTP id A4915DA075D
	for <linux-nfs@vger.kernel.org>; Tue,  5 Feb 2008 17:51:06 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS List,

I've been trying to set up some linux clients to work with a Mac OS X  
10.5 (Leopard) server.  So far I've made some good progress, but run  
into a few problems with Kerberized NFS.  I have the ssh server on  
the linux client fully kerberized with ticket forwarding.  I also  
have the users' home directories mounting from the mac server with  
autofs with sec=krb5.  Users can log in, see their files, and  
everything seems to work great.

The problem is that in syslog I get these errors repeatedly...
> Feb  5 17:31:39 myclient.domain.com rpc.gssd[8137]: WARNING: Failed  
> to create krb5 context for user with uid 0 with any credentials  
> cache for server myserver.domain.com
> Feb  5 17:31:39 myclient.domain.com rpc.gssd[8137]: Failed to write  
> error downcall!


It seems that whenever root wants to look at the mounted filesystem  
(when running df, for example), it doesn't have permission.  Now I  
know that it's supposed to use machine credentials, and that it  
currently only works with "des-cbc-crc:normal".  I wasn't sure if  
that applied to the server's nfs principal as well, but I did it just  
to be safe.  Here's what I've got in the keytabs...

Client keytab:
>    3 nfs/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
>    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (Triple DES cbc mode with  
> HMAC/sha1)
>    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (ArcFour with HMAC/md5)
>    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)


Server keytab:
> ....
>    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (Triple DES cbc mode with  
> HMAC/sha1)
>    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (ArcFour with HMAC/md5)
>    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
>    4 nfs/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
> ....


I also recreated the principals on the KDC, and specified only the  
one key type (des-cbc-crc:normal).  Again, not sure if that was  
necessary or not.


I can run rpc.gssd with the -n flag, and the error output changes to  
this...

# rpc.gssd -f -n
> ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS  
> failure.  Minor code may provide more information - Unknown code  
> krb5 195
> WARNING: Failed to create krb5 context for user with uid 0 for  
> server myserver.domain.com
> Failed to write error downcall!



If I crank up the verbosity of the output, I get this:

# rpc.gssd -f -vvv
> handling krb5 upcall
> Full hostname for 'myserver.domain.com' is 'myserver.domain.com'
> Full hostname for 'myclient.domain.com' is 'myclient.domain.com'
> Key table entry not found while getting keytab entry for 'root/ 
> myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org'
> Success getting keytab entry for 'nfs/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org'
> Successfully obtained machine credentials for principal 'nfs/ 
> myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org' stored in ccache 'FILE:/tmp/ 
> krb5cc_machine_DOMAIN.COM'
> INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_DOMAIN.COM' are  
> good until 1202297948
> using FILE:/tmp/krb5cc_machine_DOMAIN.COM as credentials cache for  
> machine creds
> using environment variable to select krb5 ccache FILE:/tmp/ 
> krb5cc_machine_DOMAIN.COM
> creating context using fsuid 0 (save_uid 0)
> creating tcp client for server myserver.domain.com
> creating context with server nfs-mXuENlnwU4l31WWMw7KoMkEOCMrvLtNR@public.gmane.org
> WARNING: Failed to create krb5 context for user with uid 0 for  
> server myserver.domain.com
> WARNING: Failed to create krb5 context for user with uid 0 with  
> credentials cache FILE:/tmp/krb5cc_machine_DOMAIN.COM for server  
> myserver.domain.com
> WARNING: Failed to create krb5 context for user with uid 0 with any  
> credentials cache for server myserver.domain.com
> doing error downcall
> Failed to write error downcall!



Can anybody give me any hints or suggestions?

Thanks,
Luke



Notice of Confidentiality: The information transmitted is intended only for the
person or entity to which it is addressed and may contain confidential and/or
privileged material. Any review, re-transmission, dissemination or other use of
or taking of any action in reliance upon this information by persons or entities
other than the intended recipient is prohibited. If you received this in error
please contact the sender immediately by return electronic transmission and then
immediately delete this transmission including all attachments without copying,
distributing or disclosing the same.


