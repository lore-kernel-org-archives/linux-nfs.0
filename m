Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753868Ab3KUNgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Nov 2013 08:36:07 -0500
Message-ID: <528E0C8A.9070608@RedHat.com>
Date: Thu, 21 Nov 2013 08:37:14 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>, "Adamson, Andy" <William.Adamson@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to sync
 Kerberos credentials and kernel gss_contexts.
References: <1382451757-3032-1-git-send-email-andros@netapp.com>	 <1382454148.9794.72.camel@willson.li.ssimo.org>	 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>	 <1382458162.9794.85.camel@willson.li.ssimo.org>	 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>	 <1382462720.9794.131.camel@willson.li.ssimo.org>	 <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com> <1384980587.17044.49.camel@willson.li.ssimo.org>
In-Reply-To: <1384980587.17044.49.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 20/11/13 15:49, Simo Sorce wrote:
>> I think Solution 3: [nfslog/nfslogout interfaces invoked from PAM or
>> > other login system facility] is a good way to go.  Note that a PAM
>> > based solution where in the PAM would get us most of the way towards
>> > providing users with a way to login and logout of NFS kerberized
>> > shares.
>> > 
>> > Comments on an NFS PAM that will destroy GSS context for a UID upon
>> > logout?
> I prefer 3 too, let it to the login system (whether PAM based or other)
> to determine when it is time to destroy credentials, that's the only
> component that have a chance of guessing right.
> Of course you could also provide a user utility to force a purge.
> 
+1 for me on this options as well... 

But how is it known when somebody logs out? Is that PAM-able as well?

steved.
