Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40320 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934278Ab1ETUXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2011 16:23:54 -0400
Received: by pzk9 with SMTP id 9so1819842pzk.19
        for <linux-nfs@vger.kernel.org>; Fri, 20 May 2011 13:23:53 -0700 (PDT)
Message-ID: <4DD6CDD7.60503@uw.edu>
Date: Fri, 20 May 2011 13:23:51 -0700
From: Harry Edmon <harry@uw.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: 2.6.38.6 - state manager constantly respawns
References: <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com>			 <4DD1772E.9010609@uw.edu>		 <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com>			 <4DD17CB5.7010009@uw.edu> <1305575007.19725.3.camel@lade.trondhjem.org>			 <4DD17F79.305@uw.edu> <1305575656.19725.9.camel@lade.trondhjem.org>			 <20110516202059.GC1680@fieldses.org> <20110516205351.GD1680@fieldses.org>			 <4DD694DF.2060302@uw.edu> <20110520172639.GA11670@fieldses.org>		 <1305913963.12712.6.camel@lade.trondhjem.org> <4DD6C103.7090302@uw.edu>	 <1305920417.14253.15.camel@lade.trondhjem.org> <4DD6C4A3.5010709@uw.edu> <1305922283.14253.24.camel@lade.trondhjem.org>
In-Reply-To: <1305922283.14253.24.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/20/11 13:11, Trond Myklebust wrote:
> On Fri, 2011-05-20 at 12:44 -0700, Harry Edmon wrote:
>    
>>> Once a minute is rather unusual... What kind of server are you running
>>> against?
>>>
>>> If it is a Linux server, what is the value contained in the virtual file
>>> "/proc/fs/nfsd/nfsv4leasetime" ?
>>>
>>>
>>>        
>> Same as before - Debian Squeeze running 2.6.38.6.   The value of
>> /proc/fs/nfsd/nfsv4leasetime is 90 and is not something I changed.
>>      
> OK... Does 'nfsstat' on the server show any 'delegreturn' updates around
> the time when the state manager thread runs? It could just be that it is
> reaping all your unused delegations.
>
>    
That number seems to be increasing all the time, whether or not the 
state manager process appears in the accounting file.   And this is only 
the one NFS client for this sever.

-- 
  Dr. Harry Edmon			E-MAIL: harry@uw.edu
  206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
  Director of IT, College of the Environment and
  Director of Computing, Dept of Atmospheric Sciences
  University of Washington, Box 351640, Seattle, WA 98195-1640

