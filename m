Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:38674 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933357AbZKXPVS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 10:21:18 -0500
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
Message-Id: <0CF4EA0D-3D25-4E5E-ADBD-DFF8B1E7172F@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4B0BEAFD.1040701@RedHat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 0/2] Use xlog() for statd/sm-notify syslogging
Date: Tue, 24 Nov 2009 10:20:27 -0500
References: <20091123215833.26806.28348.stgit@ingres.1015granger.net> <4B0BEAFD.1040701@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Nov 24, 2009, at 9:17 AM, Steve Dickson wrote:
> On 11/23/2009 05:00 PM, Chuck Lever wrote:
>> Steve -
>>
>> As requested, here are the two patches that convert statd and
>> sm-notify to use the nfs-utils' xlog() facility, replacing local
>> variants.
>>
>> ---
> Committed and thanks for breaking them up!
>
> Question, How did you differentiate between D_CALL and D_GENERAL?
>
> I'm thinking about rolling both those types into a new xlog_debug()
> function... since that what those types seem to be...

These are existing enum values.  See support/include/xlog.h.  D_CALL  
is generally used for function tracing, more or less, and D_GENERAL is  
used as a grab bag.

The debug level is set via xlog_config() or xlog_sconfig().  It looks  
like mountd uses the whole range of values, and you can set them on  
the command line.  It would be nice if statd allowed that too.

You don't need to change or eliminate any of the values.  A putative  
xlog_debug() function might look like this:

void
xlog_debug(const char* fmt, ...)
{
         va_list args;

         va_start(args, fmt);
         xlog_backend(D_GENERAL, fmt, args);
         va_end(args);
}

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



