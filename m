Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-vbr6.xs4all.nl ([194.109.24.26]:1947 "EHLO
	smtp-vbr6.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298Ab3DXPBE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 11:01:04 -0400
Message-ID: <5177F390.4020908@xs4all.net>
Date: Wed, 24 Apr 2013 17:00:32 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
MIME-Version: 1.0
To: Peter Staubach <pstaubach@exagrid.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] RFC: nfs client: lower number of NFS ops in some
 circumstances
References: <20130409124600.GA15201@xs4all.net> <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5E37A3C6@IT-1874.Isys.com>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5E37A3C6@IT-1874.Isys.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/04/13 17:18, Peter Staubach wrote:
> Miquel van Smoorenburg wrote:
>>
>> These NFS client patches are posted as an RFC - request for comment.
>>
>> The idea behind these patches is to make it possible to cut down on
>> the number of NFS operations used when opening a file in certain
>> circumstances and environments (esp. mostly-readonly environments).
>
> Outside of possibly reducing the overall RPC count between the NFS
> client and the NFS server, was a difference measured in the overall
> performance of the website, from the customer's viewpoint?

(Sorry, it took a while before I could run these tests)

Yes- mostly tests with a webbrowser, as in "does it 'feel' faster",
which is hard to quantify objectively.

We also ran some more objective tests, which I re-ran just now.

I took one of our servers out of the cluster, and did some tests on it.
I ran a "wget http://customer-site.nl/" on it repeatedly with different
mount options. The customer testsite is a joomla site (one of the
'modular' CMSes that stats/opens a lot of files for each page-request).

2 sessions below, each session was started with an empty cache.


1. Mountoptions: rw,nosuid,tcp,noatime,vers=3

   request    request time (wget)
   1          0m1.287s
   2          0m0.550s
   3          0m0.453s
   4          0m0.343s
   5          0m0.379s

   nfsstat:

   Client rpc stats:
   calls      retrans    authrefrsh
   2612       0          2612    

   Client nfs v3:
   null         getattr      setattr      lookup       access       readlink     
   0         0% 1308     50% 0         0% 416      15% 667      25% 3         0% 
   read         write        create       mkdir        symlink      mknod        
   216       8% 0         0% 0         0% 0         0% 0         0% 0         0% 
   remove       rmdir        rename       link         readdir      readdirplus  
   0         0% 0         0% 0         0% 0         0% 0         0% 2         0% 
   fsstat       fsinfo       pathconf     commit       
   0         0% 0         0% 0         0% 0         0% 

2. Mountoptions: rw,nosuid,tcp,noatime,noaccesscheck,sloppycto=3,vers=3

   request    request time (wget)
   1          0m0.787s
   2          0m0.376s
   3          0m0.385s
   4          0m0.324s
   5          0m0.338s

   nfsstat:

   Client rpc stats:
   calls      retrans    authrefrsh
   1539       0          1539    

   Client nfs v3:
   null         getattr      setattr      lookup       access       readlink     
   0         0% 902      58% 0         0% 416      27% 0         0% 3         0% 
   read         write        create       mkdir        symlink      mknod        
   216      14% 0         0% 0         0% 0         0% 0         0% 0         0% 
   remove       rmdir        rename       link         readdir      readdirplus  
   0         0% 0         0% 0         0% 0         0% 0         0% 2         0% 
   fsstat       fsinfo       pathconf     commit       
   0         0% 0         0% 0         0% 0         0% 


You can clearly see that with the new mount options the number of NFS requests
is way lower, and page loading time (esp. for the first request) has gone down.
The number of lookups and reads is exactly the same, but the second nfsstat has
zero 'access' calls and 45% less 'getattr' calls.

Mike.
