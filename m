Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19030 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbbCZR6L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2015 13:58:11 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: Connectathon Issues
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55143FAF.7090200@RedHat.com>
Date: Thu, 26 Mar 2015 12:57:56 -0500
Cc: Rupert Dance <rsdance@soft-forge.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <02E76CFB-C575-4267-83A9-448CB69AC8C6@oracle.com>
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com> <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com> <550AE575.4000104@RedHat.com> <003701d06265$b85ce8e0$2916baa0$@soft-forge.com> <55143FAF.7090200@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 26, 2015, at 12:19 PM, Steve Dickson <SteveD@redhat.com> wrote:

>> There are several other combinations that cause other errors:
>> 
>> 1. The test hangs and no error is reported.  In these cases the client
>> system MUST be restarted before it becomes usable again. The server system
>> is restarted to get back to a known good state and clear the exports before
>> restarting testing
>> 
>> 2. Connectathon Basic test hangs with the client system displaying: ./test5:
>> read and write
> Is it really hung or is it just slow? On the client, use tshark host <server> 
> to see if there is anything going over the wire…

I’m guessing Rupert is using NFS/RDMA. If true, tshark is not going to
be helpful.

Rupert, what is the output of “uname -a” on your systems?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



