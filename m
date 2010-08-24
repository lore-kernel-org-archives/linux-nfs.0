Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:50721 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933619Ab0HXXLB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 19:11:01 -0400
Received: by pvg2 with SMTP id 2so2825729pvg.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 16:11:00 -0700 (PDT)
Message-ID: <4C745182.2080206@uw.edu>
Date: Tue, 24 Aug 2010 16:10:58 -0700
From: Harry Edmon <harry@uw.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
References: <4C7407D2.1040304@uw.edu> <20100824225857.GA7283@fieldses.org>
In-Reply-To: <20100824225857.GA7283@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Tue, Aug 24, 2010 at 10:56:34AM -0700, Harry Edmon wrote:
>   
>> I am having a problem getting odd ESTALE (Stale NFS file handle)
>> errors.   The server and client are both amd64 architecture.   I am
>> runnning a simple csh script on the client with the following:
>>
>> if (! -e /home/disk/data/gempak/upperair/latest ) then
>>    mkdir /home/disk/data/gempak/upperair/latest
>> endif
>>
>> The script randomly comes back with:
>>
>>  mkdir: cannot create directory
>> `/home/disk/data/gempak/model/latest': File exists
>>     
>
> Why is it "model" here and "upperair" in the above?
>   
OOPS.  The actual script has both, and I have had failure on both.   I 
was trying to simplify my report, and ended up mixed the two.   So 
change above the script to:

if (! -e /home/disk/data/gempak/model/latest ) then
   mkdir /home/disk/data/gempak/model/latest
endif



>   
>> When I do an strace I am seeing the following when it fails:
>>
>> 20745 stat("/home/disk/data/gempak/model/latest", 0x7fff56ed9580) = -1 ESTALE (Stale NFS file handle)
>>
>> ...
>>
>> 20751 mkdir("/home/disk/data/gempak/model/latest", 0777) = -1 EEXIST (File exists)
>>     
>
> Could you give a more complete description of the code that's running?
> (For example: how is "latest" being removed, and how do you know that
> "latest" isn't created after checking whether it exists but before the
> mkdir?)
>
> --b
>   
Actually, the directory never gets removed.   This code is in the script 
just as a emergency check in case it is moved to a different disk and 
the directory structure has not yet been created.  So it should never 
get to the "mkdir", in fact the directory has entries that date from 
2007.   I have other files that never change in other scripts that I am 
seeing the "ESTALE" error when "stat" is run on them, so it is a more 
universal problem on this client/server setup than just this example.
>   
>> The kernel version of the client does not matter (I have tried
>> 2.6.34.5 and 2.6.35.3).   But the server kernel does matter.   It
>> occurs with 2.6.35 and 2.6.35.3.   It does not with 2.6.34.5.
>>
>> The ESTALE only occurs with "stat" and "lstat" in the scripts I have tried.  Attached is my configuration file from the server.  The mount on the client is:
>>
>> imist2:/home/data on /home/disk/data type nfs (rw,noatime,intr,proto=tcp,addr=192.168.1.12)
>>
>>
>> Any ideas?
>>     


-- 
 Dr. Harry Edmon			E-MAIL: harry@uw.edu
 206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
 Director of IT, College of the Environment and
 Director of Computing, Dept of Atmospheric Sciences
 University of Washington, Box 351640, Seattle, WA 98195-1640

