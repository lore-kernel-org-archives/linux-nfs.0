From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Thu, 19 Mar 2009 12:37:34 -0400
Message-ID: <E0D0AAB2-04FA-44CE-B3AE-FD8161FDE748@oracle.com>
References: <49B57FB2.9020000@RedHat.com>	<A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>	<49BFFDA6.8090500@RedHat.com>	<C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>	<49C0F20C.6030208@RedHat.com>	<6B0D5E55-637D-4C99-B79D-57BB3D5B2E0B@oracle.com>
	<49C13928.8040806@RedHat.com> <49C228D3.4070005@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49C228D3.4070005@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 19, 2009, at Mar 19, 2009, 7:13 AM, Steve Dickson wrote:
> Steve Dickson wrote:
>> Chuck Lever wrote:
>>> Our defaults should be settings that work well out of the box in  
>>> most environments.
>>> If that isn't the case yet for NFSv4, then we shouldn't make it  
>>> the default.
>> Believe me.. with all the push back I'm getting from both the  
>> client and
>> server side... I being to think the Linux community simply does not  
>> want
>> move forward... but unfortunately I can accept that as option...  
>> which
>> the the reason I will continue to push for changes that will move  
>> us forward...
> This comment was uncalled for and I hope it does not imped on the  
> productive
> dialogue we were having...

I should have made it clear that I don't have any problem with having  
NFSv4 as the default.  My interest is that our NFSv4 implementation is  
ready for our users when it becomes the default, and our development  
team has a reasonably good understanding of what the problems will  
be.  When NFSv4 becomes the default, I want it to be a step forward.

I currently don't see the benefit a mount config file would add for an  
NFSv4 transition.  It's something we will have to live with for a long  
while, so I think we should take the time and effort to get it right.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
