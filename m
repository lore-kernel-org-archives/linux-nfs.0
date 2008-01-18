From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 13:17:24 -0500
Message-ID: <247ED9F6-F190-4493-B5BA-76A2904179F4@oracle.com>
References: <4790C756.2040704@redhat.com> <63F84201-9D38-4588-B237-A15138E94C5A@oracle.com> <4790D9F3.2070503@redhat.com> <451AC300-674E-4DBE-869F-08A9184051B3@oracle.com> <4790E227.506@redhat.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4790E227.506@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peter-

On Jan 18, 2008, at 12:30 PM, Peter Staubach wrote:
> Chuck Lever wrote:
>> On Jan 18, 2008, at 11:55 AM, Peter Staubach wrote:
>>> Chuck Lever wrote:
>>>> Hi Peter-
>>>>
>>>> On Jan 18, 2008, at 10:35 AM, Peter Staubach wrote:
>>> and the window in between the revalidation
>>> and the actual use of the file handle associated with each
>>> dentry/inode pair.
>>
>> A use case or two would be useful to explore (on linux-nfs or  
>> linux-fsdevel, rather than lkml).
>
> I created a bunch of use cases in the gensyscall.c program that
> I attached to the original description of the problem and my
> proposed solution.  It was very useful in generating many, many
> ESTALE errors over the wire from a variety of different over the
> wire operations, which were originally getting returned to the
> user level.

The gensyscall.c program is what I would call a set of unit test, btw.

This is not the same as a use case, which would include information  
about the application environment, its users, a detailed description  
of current system behavior, and some discussion of alternatives for  
improving it (including doing nothing).

A test case is written in a programming language, a use case is  
written in a natural language.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
